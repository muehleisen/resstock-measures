# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'csv'
if File.exists? File.absolute_path(File.join(File.dirname(__FILE__), "../../lib/resources/measures/HPXMLtoOpenStudio/resources")) # Hack to run ResStock on AWS
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), "../../lib/resources/measures/HPXMLtoOpenStudio/resources"))
elsif File.exists? File.absolute_path(File.join(File.dirname(__FILE__), "../../resources/measures/HPXMLtoOpenStudio/resources")) # Hack to run ResStock unit tests locally
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), "../../resources/measures/HPXMLtoOpenStudio/resources"))
elsif File.exists? File.join(OpenStudio::BCLMeasure::userMeasuresDir.to_s, "HPXMLtoOpenStudio/resources") # Hack to run measures in the OS App since applied measures are copied off into a temporary directory
  resources_path = File.join(OpenStudio::BCLMeasure::userMeasuresDir.to_s, "HPXMLtoOpenStudio/resources")
else
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), "../HPXMLtoOpenStudio/resources"))
end
require File.join(resources_path, "weather")
require File.join(resources_path, "unit_conversions")
require File.join(resources_path, "geometry")
require File.join(resources_path, "hvac")
require File.join(resources_path, "waterheater")

# start the measure
class TimeseriesCSVExport < OpenStudio::Measure::ReportingMeasure
  # human readable name
  def name
    return "Timeseries CSV Export"
  end

  # human readable description
  def description
    return "Exports timeseries output data to csv."
  end

  def reporting_frequency_map
    return {
      "Timestep" => "Zone Timestep",
      "Hourly" => "Hourly",
      "Daily" => "Daily",
      # "Monthly" => "Monthly",
      "RunPeriod" => "Run Period"
    }
  end

  # define the arguments that the user will input
  def arguments()
    args = OpenStudio::Measure::OSArgumentVector.new

    # make an argument for the frequency
    reporting_frequency_chs = OpenStudio::StringVector.new
    reporting_frequency_map.keys.each do |reporting_frequency_ch|
      reporting_frequency_chs << reporting_frequency_ch
    end
    arg = OpenStudio::Measure::OSArgument::makeChoiceArgument("reporting_frequency", reporting_frequency_chs, true)
    arg.setDisplayName("Reporting Frequency")
    arg.setDescription("The frequency at which to report timeseries output data.")
    arg.setDefaultValue("Hourly")
    args << arg

    # make an argument for including optional end use subcategories
    arg = OpenStudio::Measure::OSArgument::makeBoolArgument("include_enduse_subcategories", true)
    arg.setDisplayName("Include End Use Subcategories")
    arg.setDescription("Whether to report end use subcategories: appliances, plug loads, fans, large uncommon loads.")
    arg.setDefaultValue(false)
    args << arg

    # make an argument for optional output variables
    arg = OpenStudio::Measure::OSArgument::makeStringArgument("output_variables", false)
    arg.setDisplayName("Output Variables")
    arg.setDescription("Specify a comma-separated list of output variables to report. (See EnergyPlus's rdd file for available output variables.)")
    args << arg

    return args
  end

  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    return OpenStudio::IdfObjectVector.new if runner.halted

    reporting_frequency = runner.getStringArgumentValue("reporting_frequency", user_arguments)
    include_enduse_subcategories = runner.getBoolArgumentValue("include_enduse_subcategories", user_arguments)
    output_variables = runner.getOptionalStringArgumentValue("output_variables", user_arguments)
    output_vars = []
    if output_variables.is_initialized
      output_vars = output_variables.get
      output_vars = output_vars.split(",")
      output_vars = output_vars.collect { |x| x.strip }
    end

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    output_meters = OutputMeters.new(model, runner, reporting_frequency, include_enduse_subcategories)
    results = output_meters.create_custom_building_unit_meters

    output_vars.each do |output_var|
      results << OpenStudio::IdfObject.load("Output:Variable,*,#{output_var},#{reporting_frequency};").get
    end

    results << OpenStudio::IdfObject.load("Output:Meter,Electricity:Facility,#{reporting_frequency};").get

    return results
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(), user_arguments)
      return false
    end

    # Assign the user inputs to variables
    reporting_frequency = runner.getStringArgumentValue("reporting_frequency", user_arguments)
    include_enduse_subcategories = runner.getBoolArgumentValue("include_enduse_subcategories", user_arguments)
    output_variables = runner.getOptionalStringArgumentValue("output_variables", user_arguments)
    output_vars = []
    if output_variables.is_initialized
      output_vars = output_variables.get
      output_vars = output_vars.split(",")
      output_vars = output_vars.collect { |x| x.strip }
    end

    # Get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

    # Get datetimes
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
        end
      end
    end
    if ann_env_pd == false
      runner.registerError("Can't find a weather runperiod, make sure you ran an annual simulation, not just the design days.")
      return false
    end

    datetimes = []
    timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency_map[reporting_frequency], "Electricity:Facility", "").get # assume every house consumes some electricity
    timeseries.dateTimes.each do |datetime|
      datetimes << format_datetime(datetime.to_s)
    end

    total_site_units = "MBtu"
    elec_site_units = "kWh"
    gas_site_units = "therm"
    other_fuel_site_units = "MBtu"

    # Get the timestamps for actual year epw file, and the number of intervals per hour
    weather = WeatherProcess.new(model, runner)
    if weather.error?
      return false
    end

    # Initialize timeseries hash which will be exported to csv
    timeseries = {}
    timeseries["Time"] = datetimes # timestamps from the sqlfile (TMY)
    actual_year_timestamps = weather.actual_year_timestamps(reporting_frequency)
    unless actual_year_timestamps.empty?
      timeseries["Time"] = actual_year_timestamps # timestamps constructed using run period and Time class (AMY)
    end
    if timeseries["Time"].length != datetimes.length
      runner.registerError("The timestamps array length does not equal that of the sqlfile timeseries. You may be ignoring leap days in your AMY weather file.")
      return false
    end

    output_meters = OutputMeters.new(model, runner, reporting_frequency, include_enduse_subcategories)

    electricity = output_meters.electricity(sqlFile, ann_env_pd)
    natural_gas = output_meters.natural_gas(sqlFile, ann_env_pd)
    fuel_oil = output_meters.fuel_oil(sqlFile, ann_env_pd)
    propane = output_meters.propane(sqlFile, ann_env_pd)

    # ELECTRICITY

    report_ts_output(runner, timeseries, "total_site_electricity_kwh", electricity.total_end_uses, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "net_site_electricity_kwh", electricity.total_end_uses - electricity.photovoltaics, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_heating_kwh", electricity.heating, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_central_system_heating_kwh", electricity.central_heating, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_cooling_kwh", electricity.cooling, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_central_system_cooling_kwh", electricity.central_cooling, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_interior_lighting_kwh", electricity.interior_lighting, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_exterior_lighting_kwh", electricity.exterior_lighting, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_interior_equipment_kwh", electricity.interior_equipment, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_fans_heating_kwh", electricity.fans_heating, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_fans_cooling_kwh", electricity.fans_cooling, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_pumps_heating_kwh", electricity.pumps_heating, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_central_system_pumps_heating_kwh", electricity.central_pumps_heating, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_pumps_cooling_kwh", electricity.pumps_cooling, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_central_system_pumps_cooling_kwh", electricity.central_pumps_cooling, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_water_systems_kwh", electricity.water_systems, "GJ", elec_site_units)
    report_ts_output(runner, timeseries, "electricity_pv_kwh", electricity.photovoltaics, "GJ", elec_site_units)

    # NATURAL GAS

    report_ts_output(runner, timeseries, "total_site_natural_gas_therm", natural_gas.total_end_uses, "GJ", gas_site_units)
    report_ts_output(runner, timeseries, "natural_gas_heating_therm", natural_gas.heating, "GJ", gas_site_units)
    report_ts_output(runner, timeseries, "natural_gas_central_system_heating_therm", natural_gas.central_heating, "GJ", gas_site_units)
    report_ts_output(runner, timeseries, "natural_gas_interior_equipment_therm", natural_gas.interior_equipment, "GJ", gas_site_units)
    report_ts_output(runner, timeseries, "natural_gas_water_systems_therm", natural_gas.water_systems, "GJ", gas_site_units)

    # FUEL OIL

    report_ts_output(runner, timeseries, "total_site_fuel_oil_mbtu", fuel_oil.total_end_uses, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "fuel_oil_heating_mbtu", fuel_oil.heating, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "fuel_oil_central_system_heating_mbtu", fuel_oil.central_heating, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "fuel_oil_interior_equipment_mbtu", fuel_oil.interior_equipment, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "fuel_oil_water_systems_mbtu", fuel_oil.water_systems, "GJ", other_fuel_site_units)

    # PROPANE

    report_ts_output(runner, timeseries, "total_site_propane_mbtu", propane.total_end_uses, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "propane_heating_mbtu", propane.heating, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "propane_central_system_heating_mbtu", propane.central_heating, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "propane_interior_equipment_mbtu", propane.interior_equipment, "GJ", other_fuel_site_units)
    report_ts_output(runner, timeseries, "propane_water_systems_mbtu", propane.water_systems, "GJ", other_fuel_site_units)

    # TOTAL

    totalSiteEnergy = electricity.total_end_uses +
                      natural_gas.total_end_uses +
                      fuel_oil.total_end_uses +
                      propane.total_end_uses

    report_ts_output(runner, timeseries, "total_site_energy_mbtu", totalSiteEnergy, "GJ", total_site_units)
    report_ts_output(runner, timeseries, "net_site_energy_mbtu", totalSiteEnergy - electricity.photovoltaics, "GJ", total_site_units)

    # END USE SUBCATEGORIES

    if include_enduse_subcategories
      report_ts_output(runner, timeseries, "electricity_refrigerator_kwh", electricity.refrigerator, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_clothes_washer_kwh", electricity.clothes_washer, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_clothes_dryer_kwh", electricity.clothes_dryer, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "natural_gas_clothes_dryer_therm", natural_gas.clothes_dryer, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "propane_clothes_dryer_mbtu", propane.clothes_dryer, "GJ", other_fuel_site_units)
      report_ts_output(runner, timeseries, "electricity_cooking_range_kwh", electricity.cooking_range, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "natural_gas_cooking_range_therm", natural_gas.cooking_range, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "propane_cooking_range_mbtu", propane.cooking_range, "GJ", other_fuel_site_units)
      report_ts_output(runner, timeseries, "electricity_dishwasher_kwh", electricity.dishwasher, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_plug_loads_kwh", electricity.plug_loads, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_house_fan_kwh", electricity.house_fan, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_range_fan_kwh", electricity.range_fan, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_bath_fan_kwh", electricity.bath_fan, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_ceiling_fan_kwh", electricity.ceiling_fan, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_extra_refrigerator_kwh", electricity.extra_refrigerator, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_freezer_kwh", electricity.freezer, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_pool_heater_kwh", electricity.pool_heater, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "natural_gas_pool_heater_therm", natural_gas.pool_heater, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "electricity_pool_pump_kwh", electricity.pool_pump, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_hot_tub_heater_kwh", electricity.hot_tub_heater, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "natural_gas_hot_tub_heater_therm", natural_gas.hot_tub_heater, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "electricity_hot_tub_pump_kwh", electricity.hot_tub_pump, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "natural_gas_grill_therm", natural_gas.grill, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "natural_gas_lighting_therm", natural_gas.lighting, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "natural_gas_fireplace_therm", natural_gas.fireplace, "GJ", gas_site_units)
      report_ts_output(runner, timeseries, "electricity_well_pump_kwh", electricity.well_pump, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_garage_lighting_kwh", electricity.garage_lighting, "GJ", elec_site_units)
      report_ts_output(runner, timeseries, "electricity_exterior_holiday_lighting_kwh", electricity.exterior_holiday_lighting, "GJ", elec_site_units)
    end

    output_vars.each do |output_var|
      sqlFile.availableKeyValues(ann_env_pd, reporting_frequency_map[reporting_frequency], output_var).each do |key_value|
        request = sqlFile.timeSeries(ann_env_pd, reporting_frequency_map[reporting_frequency], output_var, key_value)
        next if request.empty?

        request = request.get
        vals = request.values
        old_units = request.units
        new_units = old_units
        if old_units == "C"
          new_units = "F"
        end
        name = "#{output_var.upcase} (#{key_value})"
        unless new_units.empty?
          name += " [#{new_units}]"
        end
        report_ts_output(runner, timeseries, name, vals, old_units, new_units)
      end
    end

    sqlFile.close

    csv_path = File.expand_path("../enduse_timeseries.csv")
    CSV.open(csv_path, "wb") do |csv|
      csv << timeseries.keys
      rows = timeseries.values.transpose
      rows.each do |row|
        csv << row
      end
    end

    return true
  end # end the run method

  def report_ts_output(runner, timeseries, name, vals, os_units, desired_units)
    timeseries[name] = []
    timeseries["Time"].each_with_index do |ts, i|
      timeseries[name] << UnitConversions.convert(vals[i], os_units, desired_units)
    end
    runner.registerInfo("Exporting #{name}.")
  end

  def format_datetime(date_time)
    date_time.gsub!("-", "/")
    date_time.gsub!("Jan", "01")
    date_time.gsub!("Feb", "02")
    date_time.gsub!("Mar", "03")
    date_time.gsub!("Apr", "04")
    date_time.gsub!("May", "05")
    date_time.gsub!("Jun", "06")
    date_time.gsub!("Jul", "07")
    date_time.gsub!("Aug", "08")
    date_time.gsub!("Sep", "09")
    date_time.gsub!("Oct", "10")
    date_time.gsub!("Nov", "11")
    date_time.gsub!("Dec", "12")
    return date_time
  end
end

# register the measure to be used by the application
TimeseriesCSVExport.new.registerWithApplication
