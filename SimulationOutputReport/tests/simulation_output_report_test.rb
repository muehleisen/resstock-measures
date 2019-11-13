require_relative '../../../test/minitest_helper'
require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class SimulationOutputReportTest < MiniTest::Test
  def test_SFD_1story_FB_UA_GRG_MSHP_FuelTanklessWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 1633.82,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2176.31,
      "Wall Area, Below-Grade (ft^2)" => 1633.82 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 4500,
      "Floor Area, Attic (ft^2)" => 2250,
      "Floor Area, Lighting (ft^2)" => 4788,
      "Roof Area (ft^2)" => 2837.57,
      "Window Area (ft^2)" => 168.74,
      "Door Area (ft^2)" => 30,
      "Duct Surface Area (ft^2)" => 1440,
      "Size, Heating System (kBtu/h)" => 60, # hp, not backup
      "Size, Heating Supplemental System (kBtu/h)" => 100, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 0,
    }
    _test_cost_multipliers("SFD_1story_FB_UA_GRG_MSHP_FuelTanklessWH.osm", cost_multipliers)
  end

  def test_SFD_1story_FB_UA_GRG_RoomAC_ElecBoiler_FuelTanklessWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 1129.42,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 1498.30,
      "Wall Area, Below-Grade (ft^2)" => 1129.42 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2288,
      "Roof Area (ft^2)" => 1440.03,
      "Window Area (ft^2)" => 106.84,
      "Door Area (ft^2)" => 40,
      "Duct Surface Area (ft^2)" => 640,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 36,
      "Size, Water Heater (gal)" => 0,
    }
    _test_cost_multipliers("SFD_1story_FB_UA_GRG_RoomAC_ElecBoiler_FuelTanklessWH.osm", cost_multipliers)
  end

  def test_SFD_1story_UB_UA_ASHP2_HPWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 1828.95,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2245.61,
      "Wall Area, Below-Grade (ft^2)" => 1828.95,
      "Floor Area, Conditioned (ft^2)" => 3000,
      "Floor Area, Attic (ft^2)" => 3000,
      "Floor Area, Lighting (ft^2)" => 3000,
      "Roof Area (ft^2)" => 3354.10,
      "Window Area (ft^2)" => 213.83,
      "Door Area (ft^2)" => 40,
      "Duct Surface Area (ft^2)" => 1110,
      "Size, Heating System (kBtu/h)" => 60, # hp, not backup
      "Size, Heating Supplemental System (kBtu/h)" => 100, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 50,
    }
    _test_cost_multipliers("SFD_1story_UB_UA_ASHP2_HPWH.osm", cost_multipliers)
  end

  def test_SFD_1story_UB_UA_GRG_ACV_FuelFurnace_HPWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2275.56,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3130.55,
      "Wall Area, Below-Grade (ft^2)" => 2275.56 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 4500,
      "Floor Area, Attic (ft^2)" => 4500,
      "Floor Area, Lighting (ft^2)" => 4788,
      "Roof Area (ft^2)" => 5353.15,
      "Window Area (ft^2)" => 352.22,
      "Door Area (ft^2)" => 20,
      "Duct Surface Area (ft^2)" => 1665,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 50,
    }
    _test_cost_multipliers("SFD_1story_UB_UA_GRG_ACV_FuelFurnace_HPWH.osm", cost_multipliers)
  end

  def test_SFD_2story_CS_UA_AC2_FuelBoiler_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2111.88,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2250.77,
      "Wall Area, Below-Grade (ft^2)" => 527.97,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 250.52,
      "Door Area (ft^2)" => 20,
      "Duct Surface Area (ft^2)" => 640,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 40,
    }
    _test_cost_multipliers("SFD_2story_CS_UA_AC2_FuelBoiler_FuelTankWH.osm", cost_multipliers)
  end

  def test_SFD_2story_CS_UA_GRG_ASHPV_FuelTanklessWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2778.52,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3196.86,
      "Wall Area, Below-Grade (ft^2)" => 646.63 - 96.0,
      "Floor Area, Conditioned (ft^2)" => 3000,
      "Floor Area, Attic (ft^2)" => 1644,
      "Floor Area, Lighting (ft^2)" => 3288,
      "Roof Area (ft^2)" => 1838.05,
      "Window Area (ft^2)" => 422.51,
      "Door Area (ft^2)" => 20,
      "Duct Surface Area (ft^2)" => 960,
      "Size, Heating System (kBtu/h)" => 60, # hp, not backup
      "Size, Heating Supplemental System (kBtu/h)" => 100, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 0,
    }
    _test_cost_multipliers("SFD_2story_CS_UA_GRG_ASHPV_FuelTanklessWH.osm", cost_multipliers)
  end

  def test_SFD_2story_FB_UA_GRG_AC1_ElecBaseboard_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2819.59,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3244.58,
      "Wall Area, Below-Grade (ft^2)" => 1313.79 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 4500,
      "Floor Area, Attic (ft^2)" => 1692,
      "Floor Area, Lighting (ft^2)" => 4788,
      "Roof Area (ft^2)" => 1891.72,
      "Window Area (ft^2)" => 468.61,
      "Door Area (ft^2)" => 20,
      "Duct Surface Area (ft^2)" => 1620,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 40,
    }
    _test_cost_multipliers("SFD_2story_FB_UA_GRG_AC1_ElecBaseboard_FuelTankWH.osm", cost_multipliers)
  end

  def test_SFD_2story_FB_UA_GRG_AC1_UnitHeater_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2819.59,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3244.58,
      "Wall Area, Below-Grade (ft^2)" => 1313.79 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 4500,
      "Floor Area, Attic (ft^2)" => 1692,
      "Floor Area, Lighting (ft^2)" => 4788,
      "Roof Area (ft^2)" => 1891.72,
      "Window Area (ft^2)" => 468.61,
      "Door Area (ft^2)" => 20,
      "Duct Surface Area (ft^2)" => 1620,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 40,
    }
    _test_cost_multipliers("SFD_2story_FB_UA_GRG_AC1_UnitHeater_FuelTankWH.osm", cost_multipliers)
  end

  def test_SFD_2story_FB_UA_GRG_GSHP_ElecTanklessWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2819.58,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3244.58,
      "Wall Area, Below-Grade (ft^2)" => 1313.79 - 192.0,
      "Floor Area, Conditioned (ft^2)" => 4500,
      "Floor Area, Attic (ft^2)" => 1692,
      "Floor Area, Lighting (ft^2)" => 4788,
      "Roof Area (ft^2)" => 1891.72,
      "Window Area (ft^2)" => 311.03,
      "Door Area (ft^2)" => 30,
      "Duct Surface Area (ft^2)" => 1620,
      "Size, Heating System (kBtu/h)" => 60, # hp, not backup
      "Size, Heating Supplemental System (kBtu/h)" => 100, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 0,
    }
    _test_cost_multipliers("SFD_2story_FB_UA_GRG_GSHP_ElecTanklessWH.osm", cost_multipliers)
  end

  def test_SFD_2story_PB_UA_ElecFurnace_ElecTankWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2111.89,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2778.75,
      "Wall Area, Below-Grade (ft^2)" => 0,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 342.25,
      "Door Area (ft^2)" => 40,
      "Duct Surface Area (ft^2)" => 640,
      "Size, Heating System (kBtu/h)" => 100,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 0,
      "Size, Water Heater (gal)" => 66,
    }
    _test_cost_multipliers("SFD_2story_PB_UA_ElecFurnace_ElecTankWH.osm", cost_multipliers)
  end

  def test_SFD_2story_S_UA_GRG_ASHP1_FuelTanklessWH
    cost_multipliers = {
      "Fixed (1)" => 1,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2778.52,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3196.86,
      "Wall Area, Below-Grade (ft^2)" => 0,
      "Floor Area, Conditioned (ft^2)" => 3000,
      "Floor Area, Attic (ft^2)" => 1644,
      "Floor Area, Lighting (ft^2)" => 3288,
      "Roof Area (ft^2)" => 1838.05,
      "Window Area (ft^2)" => 304.73,
      "Door Area (ft^2)" => 40,
      "Duct Surface Area (ft^2)" => 960,
      "Size, Heating System (kBtu/h)" => 60, # hp, not backup
      "Size, Heating Supplemental System (kBtu/h)" => 100, # backup
      "Size, Cooling System (kBtu/h)" => 60,
      "Size, Water Heater (gal)" => 0,
    }
    _test_cost_multipliers("SFD_2story_S_UA_GRG_ASHP1_FuelTanklessWH.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_Furnace_RoomAC_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 100 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 36 * 4,
      "Size, Water Heater (gal)" => 30 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_Furnace_RoomAC_FuelTankWH.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_Furnace_RoomAC_FuelTankWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      # "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 100 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 36 * 4,
      "Size, Water Heater (gal)" => 30 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_Furnace_RoomAC_FuelTankWH_Collapsed.osm", cost_multipliers)
  end

  def test_MF_2story_UB_Furnace_AC1_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 100 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 30 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_Furnace_AC1_FuelTankWH.osm", cost_multipliers)
  end

  def test_MF_2story_UB_Furnace_AC1_FuelTankWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 100 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 30 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_Furnace_AC1_FuelTankWH_Collapsed.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_FuelBoiler_RoomAC_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 100 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 36 * 4,
      "Size, Water Heater (gal)" => 30 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_FuelBoiler_RoomAC_FuelTankWH.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_FuelBoiler_RoomAC_FuelTankWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      # "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 100 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 36 * 4,
      "Size, Water Heater (gal)" => 30 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_FuelBoiler_RoomAC_FuelTankWH_Collapsed.osm", cost_multipliers)
  end

  def test_MF_2story_UB_FuelBoiler_AC1_FuelTankWH
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 100 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 30 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_FuelBoiler_AC1_FuelTankWH.osm", cost_multipliers)
  end

  def test_MF_2story_UB_FuelBoiler_AC1_FuelTankWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 100 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 0, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 30 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_FuelBoiler_AC1_FuelTankWH_Collapsed.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_ASHP2_HPWH
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 60 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 100 * 4, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 4,
      "Size, Water Heater (gal)" => 50 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_ASHP2_HPWH.osm", cost_multipliers)
  end

  def test_SFA_2story_UB_ASHP2_HPWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 4,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2187.32,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 2299.82,
      # "Wall Area, Below-Grade (ft^2)" => 1093.66,
      "Floor Area, Conditioned (ft^2)" => 2000,
      "Floor Area, Attic (ft^2)" => 1000,
      "Floor Area, Lighting (ft^2)" => 2000,
      "Roof Area (ft^2)" => 1118.03,
      "Window Area (ft^2)" => 376.30,
      "Door Area (ft^2)" => 20 * 4,
      "Size, Heating System (kBtu/h)" => 60 * 4,
      "Size, Heating Supplemental System (kBtu/h)" => 100 * 4, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 4,
      "Size, Water Heater (gal)" => 50 * 4,
    }
    _test_cost_multipliers("SFA_2story_UB_ASHP2_HPWH_Collapsed.osm", cost_multipliers)
  end

  def test_MF_2story_UB_ASHP2_HPWH
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 60 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 100 * 8, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 50 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_ASHP2_HPWH.osm", cost_multipliers)
  end

  def test_MF_2story_UB_ASHP2_HPWH_Collapsed
    cost_multipliers = {
      "Fixed (1)" => 8,
      "Wall Area, Above-Grade, Conditioned (ft^2)" => 2986.66,
      "Wall Area, Above-Grade, Exterior (ft^2)" => 3306.66,
      "Wall Area, Below-Grade (ft^2)" => 1653.33,
      "Floor Area, Conditioned (ft^2)" => 4000,
      "Floor Area, Attic (ft^2)" => 0,
      "Floor Area, Lighting (ft^2)" => 4000,
      "Roof Area (ft^2)" => 2333.33,
      "Window Area (ft^2)" => 537.60,
      "Door Area (ft^2)" => 20 * 8,
      "Size, Heating System (kBtu/h)" => 60 * 8,
      "Size, Heating Supplemental System (kBtu/h)" => 100 * 8, # backup
      "Size, Cooling System (kBtu/h)" => 60 * 8,
      "Size, Water Heater (gal)" => 50 * 8,
    }
    _test_cost_multipliers("MF_2story_UB_ASHP2_HPWH_Collapsed.osm", cost_multipliers)
  end

  private

  def _test_cost_multipliers(osm_file, cost_multipliers)
    # load the test model
    model = get_model(File.dirname(__FILE__), osm_file)

    # create an instance of the measure
    measure = SimulationOutputReport.new

    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # Check for correct cost multiplier values
    cost_multipliers.each do |mult_type, mult_value|
      value = measure.get_cost_multiplier(mult_type, model, runner)
      assert(!value.nil?)
      if mult_type.include? "ft^2" or mult_type.include? "gal"
        assert_in_epsilon(mult_value, value, 0.01)
      else
        assert_in_epsilon(mult_value, value, 0.05)
      end
    end
  end
end
