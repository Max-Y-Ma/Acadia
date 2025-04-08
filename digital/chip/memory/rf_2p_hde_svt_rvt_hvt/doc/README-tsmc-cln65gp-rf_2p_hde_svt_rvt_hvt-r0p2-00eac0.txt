ARM, Inc.
High Density Two-Port Register File Compiler (RF_2P_HDE_SVT_RVT_HVT) Release Notes
TSMC CLN65GP 65nm Process, 0.974um^2 Bit Cell
-----------------------------------------------------------------------------------------------
r0p2-00eac0 (18/03/2011)

Impact on Designs Using r0p1-00eac0 Release
----------------------------------------
This section describes the impact of this release on current designs
which are using the previous release.

*** This is a mandatory update. ***

ARM Update Recommendation:

    Install version r0p2-00eac0; Discontinue using r0p1-00eac0
    
  
Impact of this Release on Major Library Components:

    o Timing data has not changed 
    o Leakage Numbers have changed
    o Gds2 and LVS netlist have changed in case of power_gating=on, bmux=on and mux=1 instances to reduce leakage in powerdown mode

The following Views can be generated from this release:

    o ASCII Datatable
    o Post-script Datasheet
    o Verilog Model
    o Synopsys Model
    o VCLEF Footprint 
    o GDSII Layout
    o LVS Netlist
    o TetraMax Model 
    o Repair and SER Verilog
    o FastScan
        
Process Technology Data
-----------------------
This section lists all of the foundry documents and technology files used to design this product.

    o SRAM 8T 1.91um by 0.51um (0.974um^2) Cell
        - 065_DP_0d97_v10_demo_array_4x4.gds, V1.0 (09/18/2009)
	- Qualified by Foundry using deviated layout rules.
    o Design Rule Document For Layout
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o Design Rule Document For Electrical Information
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o GDS Layer Usage Description File
        - Refer to Design Rule Document
          - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o DRC Command File
        - Calibre DRC Command File
          - T-N65-CL-DR-001-C1 2.0a
    o LVS Command File
        - Calibre LVS Command File
          - T-N65-CL-LS-001-C1 1.5a
    o Process Spice Models
        - Bit Cell SPICE Models  T-N65-CL-CL-007
        - Logic Models           T-N65-CL-SP-041-P1
    o Extractor Technology Files
        - Extraction LVS deck version:  V1.5a  	
	- STAR-RCXT T-N65-CL-SP-031-B1_1_2a

EDA Support
-----------

This section lists the EDA tools and versions supported for this product release. The items indicated by the "*" were used during the QA testing of this release.This set of tools and versions corresponds to ARM EDA Package 6.2-65nm.

   * Synopsys VCS (Verilog)
        - 2008.09
   * Mentor ModelSim (Verilog)
        - 6.3
   * Simulation Model SDF Compatibility
        - SDF 3.0
   * Synopsys Design Compiler
        - 2007.12
   * Synopsys Library Compiler
        - 2007.12
   * Synopsys PrimeTime SI (CCS timing)
        - 2007.12
   * Magma Talus Design (.lib)
        - 1.0
   * Cadence ETS (SignalStorm - ECSM timing)
        - 7.1
   * Cadence ETS(CeltIC NDC)
        - 7.1
   * Cadence SoC Encounter/NanoRoute (Place & Route)
        - 7.1
   * Synopsys IC Compiler (Place & Route)
        - 2007.12
   * Synopsys Tetramax
        - 2007.12-SP2
   * Mentor Graphics Calibre (GDS2, CDL)
        - v2008.4_28.20  (LVS)
        - v2009.1_26.20  (DRC)
   * Synopsys HSPICE
        - 2008.09-SP1-ENG1 (timing)
   * Synopsys HSIM
        - 2008.09-SP1 (power)
   * Adobe Acrobat Reader (PDF Documentation)
        - 5.0
   * Operating System
   	- Linux Redhat RHEL4

Technology Implementation
-------------------------

This section provides information on items that may not be included in the foundry documentation.

Characterization Corners:
        - Timing and power views characterized at the following conditions:
          fast     P/V/T = FF/1.1V/-40C
          fast     P/V/T = FF/1.1V/0C
          fast     P/V/T = FF/1.1V/125C
          slow     P/V/T = SS/0.9V/125C
          slow     P/V/T = SS/0.9V/-40C
          typical  P/V/T = TT/1.0V/25C

Mandatory Tapeout layers required for foundry:
        - GDS2 text layer 63:63,6:0 and 17:0 are allocated by foundry for IP marking.
          *** These are mandatory tapeout layers ****

Methodology
-----------
This section describes design settings applicable to this release.

    	
    o Calibre Instance LVS OPTIONS
	module load mentor/calibre/2008.4_28.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_LVS_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/lvs/lvs_deck"
        setenv VIRTUAL_CONNECT no
        setenv extract_dnwdio no
        setenv NW_RING TRUE
        setenv INSTANCE 1
        setenv EXECUTE_ERC YES
        setenv BEOL_STACK 1P9M
        setenv top2_thick 0
	setenv SPLIT_GATE FALSE
	setenv GATE_TO_PG_CHECK FALSE
	setenv FLOATING_WELL YES


       o Calibre Instance DRC OPTIONS
        module load mentor/calibre/2009.1_26.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_DRC_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/drc/drc_deck"
        setenv CAL_DFM_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/dfm/metrics_calibre.dfm.arm"
        setenv BEOL_STACK 9M_6X2Z
        setenv DATATYPE_WARNING FALSE
        setenv GUIDELINE_RES TRUE
        setenv GUIDELINE_LUP TRUE
        setenv GUIDELINE_ESD TRUE
        setenv NW_SUGGESTED TRUE
        setenv CHECK_LOW_DENSITY TRUE
        setenv FULL_CHIP FALSE
        setenv MIXED_SCHEME FALSE
        setenv DFM FALSE
        setenv NO_DENSITIES FALSE

    o HSPICE Simulation options
    	hspice-options runlvl: 3
	
    o Synopsys
        - Please note that SDF generated with tool versions above
          also require postprocessing prior to back-annotation.
          The following postprocessing scripts are available:
              - Synopsys Design Compiler
                aci/<product>/lib/sdf_postprocessors/dc_postprocessor.pl
              - Synopsys Primetime
                aci/<product>/lib/sdf_postprocessors/pt_postprocessor.pl
        - Please note that SDF generated with versions other than
          those specified above may not annotate properly due to
          various changes in the SDF output format.
    o Antenna Modeling
        - VCLEF view generator creates <instance_name>.vclef
          and <instance_name>_ant.clf side file.
        - A minimum gate area as allowed by the design rules is assumed
          to be connected to each input pin to force the router to
          connect to the input pin with an antenna clean wire.  Pin
          connections internal to the memory have been verified to
          be antenna clean.
        - The technology header information is not automatically
          appended by the generator. If needed, please append this
          information from the standard cell release.

Known Problems and Solutions
----------------------------

     o  SOCE may flag violation as below near the pin area of
        the memories during verify geometry. This is because
        SOCE looks for a fat meting spacing between PIN and
        obstruction and we do not need that.  These may be ignored.

        SPACING:Regular Wire of Net & Blockage of Cell (M1)
        Actual: 0.1 Min: 0.11
        SPACING:Regular Wire of Net & Blockage of Cell (M2)
        Actual: 0.1 Min: 0.12
        SPACING:Regular Wire of Net & Blockage of Cell (M3)
        Actual: 0.1 Min: 0.12
-----------------------------------------------------
r0p1-00eac0 (14/12/2010)

Impact on Designs Using r0p0-01eac0 Release
----------------------------------------
This section describes the impact of this release on current designs
which are using the previous release.

*** This is a mandatory update. ***

ARM Update Recommendation:

    Install version r0p1-00eac0; Discontinue using r0p0-00eac0
    
  
Impact of this Release on Major Library Components:

    o Timing data has not changed 
    o Leakage Numbers have changed
    o Gds2 and LVS netlist have changed in case of power_gating=on, bmux=on and mux=1 instances to reduce leakage in powerdown mode

The following Views can be generated from this release:

    o ASCII Datatable
    o Post-script Datasheet
    o Verilog Model
    o Synopsys Model
    o VCLEF Footprint 
    o GDSII Layout
    o LVS Netlist
    o TetraMax Model 
    o Repair and SER Verilog
        
Process Technology Data
-----------------------
This section lists all of the foundry documents and technology files used to design this product.

    o SRAM 8T 1.91um by 0.51um (0.974um^2) Cell
        - 065_DP_0d97_v10_demo_array_4x4.gds, V1.0 (09/18/2009)
	- Qualified by Foundry using deviated layout rules.
    o Design Rule Document For Layout
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o Design Rule Document For Electrical Information
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o GDS Layer Usage Description File
        - Refer to Design Rule Document
          - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o DRC Command File
        - Calibre DRC Command File
          - T-N65-CL-DR-001-C1 2.0a
    o LVS Command File
        - Calibre LVS Command File
          - T-N65-CL-LS-001-C1 1.5a
    o Process Spice Models
        - Bit Cell SPICE Models  T-N65-CL-CL-007
        - Logic Models           T-N65-CL-SP-041-P1
    o Extractor Technology Files
        - Extraction LVS deck version:  V1.5a  	
	- STAR-RCXT T-N65-CL-SP-031-B1_1_2a

EDA Support
-----------

This section lists the EDA tools and versions supported for this product release. The items indicated by the "*" were used during the QA testing of this release.This set of tools and versions corresponds to ARM EDA Package 6.2-65nm.

   * Synopsys VCS (Verilog)
        - 2008.09
   * Mentor ModelSim (Verilog)
        - 6.3
   * Simulation Model SDF Compatibility
        - SDF 3.0
   * Synopsys Design Compiler
        - 2007.12
   * Synopsys Library Compiler
        - 2007.12
   * Synopsys PrimeTime SI (CCS timing)
        - 2007.12
   * Magma Talus Design (.lib)
        - 1.0
   * Cadence ETS (SignalStorm - ECSM timing)
        - 7.1
   * Cadence ETS(CeltIC NDC)
        - 7.1
   * Cadence SoC Encounter/NanoRoute (Place & Route)
        - 7.1
   * Synopsys IC Compiler (Place & Route)
        - 2007.12
   * Synopsys Tetramax
        - 2007.12-SP2
   * Mentor Graphics Calibre (GDS2, CDL)
        - v2008.4_28.20  (LVS)
        - v2009.1_26.20  (DRC)
   * Synopsys HSPICE
        - 2008.09-SP1-ENG1 (timing)
   * Synopsys HSIM
        - 2008.09-SP1 (power)
   * Adobe Acrobat Reader (PDF Documentation)
        - 5.0
   * Operating System
   	- Linux Redhat RHEL4

Technology Implementation
-------------------------

This section provides information on items that may not be included in the foundry documentation.

Characterization Corners:
        - Timing and power views characterized at the following conditions:
          fast     P/V/T = FF/1.1V/-40C
          fast     P/V/T = FF/1.1V/0C
          fast     P/V/T = FF/1.1V/125C
          slow     P/V/T = SS/0.9V/125C
          slow     P/V/T = SS/0.9V/-40C
          typical  P/V/T = TT/1.0V/25C

Mandatory Tapeout layers required for foundry:
        - GDS2 text layer 63:63, are allocated by foundry for IP marking.
          *** These are mandatory tapeout layers ****

Methodology
-----------
This section describes design settings applicable to this release.

    	
    o Calibre Instance LVS OPTIONS
	module load mentor/calibre/2008.4_28.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_LVS_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/lvs/lvs_deck"
        setenv VIRTUAL_CONNECT no
        setenv extract_dnwdio no
        setenv NW_RING TRUE
        setenv INSTANCE 1
        setenv EXECUTE_ERC YES
        setenv BEOL_STACK 1P9M
        setenv top2_thick 0
	setenv SPLIT_GATE FALSE
	setenv GATE_TO_PG_CHECK FALSE
	setenv FLOATING_WELL YES


       o Calibre Instance DRC OPTIONS
        module load mentor/calibre/2009.1_26.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_DRC_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/drc/drc_deck"
        setenv CAL_DFM_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/dfm/metrics_calibre.dfm.arm"
        setenv BEOL_STACK 9M_6X2Z
        setenv DATATYPE_WARNING FALSE
        setenv GUIDELINE_RES TRUE
        setenv GUIDELINE_LUP TRUE
        setenv GUIDELINE_ESD TRUE
        setenv NW_SUGGESTED TRUE
        setenv CHECK_LOW_DENSITY TRUE
        setenv FULL_CHIP FALSE
        setenv MIXED_SCHEME FALSE
        setenv DFM FALSE
        setenv NO_DENSITIES FALSE

    o HSPICE Simulation options
    	hspice-options runlvl: 3
	
    o Synopsys
        - Please note that SDF generated with tool versions above
          also require postprocessing prior to back-annotation.
          The following postprocessing scripts are available:
              - Synopsys Design Compiler
                aci/<product>/lib/sdf_postprocessors/dc_postprocessor.pl
              - Synopsys Primetime
                aci/<product>/lib/sdf_postprocessors/pt_postprocessor.pl
        - Please note that SDF generated with versions other than
          those specified above may not annotate properly due to
          various changes in the SDF output format.
    o Antenna Modeling
        - VCLEF view generator creates <instance_name>.vclef
          and <instance_name>_ant.clf side file.
        - A minimum gate area as allowed by the design rules is assumed
          to be connected to each input pin to force the router to
          connect to the input pin with an antenna clean wire.  Pin
          connections internal to the memory have been verified to
          be antenna clean.
        - The technology header information is not automatically
          appended by the generator. If needed, please append this
          information from the standard cell release.

Known Problems and Solutions
----------------------------

     o  SOCE may flag violation as below near the pin area of
        the memories during verify geometry. This is because
        SOCE looks for a fat meting spacing between PIN and
        obstruction and we do not need that.  These may be ignored.

        SPACING:Regular Wire of Net & Blockage of Cell (M1)
        Actual: 0.1 Min: 0.11
        SPACING:Regular Wire of Net & Blockage of Cell (M2)
        Actual: 0.1 Min: 0.12
        SPACING:Regular Wire of Net & Blockage of Cell (M3)
        Actual: 0.1 Min: 0.12

-----------------------------------------------------------------------------------------------
r0p0-00eac0 (06/05/2010)

Impact on Designs Using r0p0-00eac0 Release
----------------------------------------
This section describes the impact of this release on current designs
which are using the previous release.

ARM Update Recommendation:

  ******* This is the initial release *******
  
Impact of this Release on Major Library Components:

The following Views can be generated from this release:

    o ASCII Datatable
    o Post-script Datasheet
    o Verilog Model
    o Synopsys Model
    o VCLEF Footprint 
    o GDSII Layout
    o LVS Netlist
    o TetraMax Model 
    o Repair and SER Verilog
        
Process Technology Data
-----------------------
This section lists all of the foundry documents and technology files used to design this product.

    o SRAM 8T 1.91um by 0.51um (0.974um^2) Cell
        - 065_DP_0d97_v10_demo_array_4x4.gds, V1.0 (09/18/2009)
	- Qualified by Foundry using deviated layout rules.
    o Design Rule Document For Layout
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o Design Rule Document For Electrical Information
        - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o GDS Layer Usage Description File
        - Refer to Design Rule Document
          - TN65CLDR001_1_4_1.pdf T-N65-CL-DR-001 (02/04/2008)
    o DRC Command File
        - Calibre DRC Command File
          - T-N65-CL-DR-001-C1 2.0a
    o LVS Command File
        - Calibre LVS Command File
          - T-N65-CL-LS-001-C1 1.5a
    o Process Spice Models
        - Bit Cell SPICE Models  T-N65-CL-CL-007
        - Logic Models           T-N65-CL-SP-041-P1
    o Extractor Technology Files
        - Extraction LVS deck version:  V1.5a  	
	- STAR-RCXT T-N65-CL-SP-031-B1_1_2a

EDA Support
-----------

This section lists the EDA tools and versions supported for this product release. The items indicated by the "*" were used during the QA testing of this release.This set of tools and versions corresponds to ARM EDA Package 6.2-65nm.

   * Synopsys VCS (Verilog)
        - 2008.09
   * Mentor ModelSim (Verilog)
        - 6.3
   * Simulation Model SDF Compatibility
        - SDF 3.0
   * Synopsys Design Compiler
        - 2007.12
   * Synopsys Library Compiler
        - 2007.12
   * Synopsys PrimeTime SI (CCS timing)
        - 2007.12
   * Magma Talus Design (.lib)
        - 1.0
   * Cadence ETS (SignalStorm - ECSM timing)
        - 7.1
   * Cadence ETS(CeltIC NDC)
        - 7.1
   * Cadence SoC Encounter/NanoRoute (Place & Route)
        - 7.1
   * Synopsys IC Compiler (Place & Route)
        - 2007.12
   * Synopsys Tetramax
        - 2007.12-SP2
   * Mentor Graphics Calibre (GDS2, CDL)
        - v2008.4_28.20  (LVS)
        - v2009.1_26.20  (DRC)
   * Synopsys HSPICE
        - 2008.09-SP1-ENG1 (timing)
   * Synopsys HSIM
        - 2008.09-SP1 (power)
   * Adobe Acrobat Reader (PDF Documentation)
        - 5.0
   * Operating System
   	- Linux Redhat RHEL4

Technology Implementation
-------------------------

This section provides information on items that may not be included in the foundry documentation.

Characterization Corners:
        - Timing and power views characterized at the following conditions:
          fast     P/V/T = FF/1.1V/-40C
          fast     P/V/T = FF/1.1V/0C
          fast     P/V/T = FF/1.1V/125C
          slow     P/V/T = SS/0.9V/125C
          slow     P/V/T = SS/0.9V/-40C
          typical  P/V/T = TT/1.0V/25C

Mandatory Tapeout layers required for foundry:
        - GDS2 text layer 63:63, are allocated by foundry for IP marking.
          *** These are mandatory tapeout layers ****

Methodology
-----------
This section describes design settings applicable to this release.

    	
    o Calibre Instance LVS OPTIONS
	module load mentor/calibre/2008.4_28.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_LVS_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/lvs/lvs_deck"
        setenv VIRTUAL_CONNECT no
        setenv extract_dnwdio no
        setenv NW_RING TRUE
        setenv INSTANCE 1
        setenv EXECUTE_ERC YES
        setenv BEOL_STACK 1P9M
        setenv top2_thick 0
	setenv SPLIT_GATE FALSE
	setenv GATE_TO_PG_CHECK FALSE
	setenv FLOATING_WELL YES


       o Calibre Instance DRC OPTIONS
        module load mentor/calibre/2009.1_26.20
        setenv TECHDIR "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre"
        setenv CAL_DRC_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/calibre/drc/drc_deck"
        setenv CAL_DFM_DECK "/projects/pipd/tsmc/cln65gplus/pdk/$PDK_REL/dfm/metrics_calibre.dfm.arm"
        setenv BEOL_STACK 9M_6X2Z
        setenv DATATYPE_WARNING FALSE
        setenv GUIDELINE_RES TRUE
        setenv GUIDELINE_LUP TRUE
        setenv GUIDELINE_ESD TRUE
        setenv NW_SUGGESTED TRUE
        setenv CHECK_LOW_DENSITY TRUE
        setenv FULL_CHIP FALSE
        setenv MIXED_SCHEME FALSE
        setenv DFM FALSE
        setenv NO_DENSITIES FALSE

    o HSPICE Simulation options
    	hspice-options runlvl: 3
	
    o Synopsys
        - Please note that SDF generated with tool versions above
          also require postprocessing prior to back-annotation.
          The following postprocessing scripts are available:
              - Synopsys Design Compiler
                aci/<product>/lib/sdf_postprocessors/dc_postprocessor.pl
              - Synopsys Primetime
                aci/<product>/lib/sdf_postprocessors/pt_postprocessor.pl
        - Please note that SDF generated with versions other than
          those specified above may not annotate properly due to
          various changes in the SDF output format.
    o Antenna Modeling
        - VCLEF view generator creates <instance_name>.vclef
          and <instance_name>_ant.clf side file.
        - A minimum gate area as allowed by the design rules is assumed
          to be connected to each input pin to force the router to
          connect to the input pin with an antenna clean wire.  Pin
          connections internal to the memory have been verified to
          be antenna clean.
        - The technology header information is not automatically
          appended by the generator. If needed, please append this
          information from the standard cell release.

Known Problems and Solutions
----------------------------

     o  SOCE may flag violation as below near the pin area of
        the memories during verify geometry. This is because
        SOCE looks for a fat meting spacing between PIN and
        obstruction and we do not need that.  These may be ignored.

        SPACING:Regular Wire of Net & Blockage of Cell (M1)
        Actual: 0.1 Min: 0.11
        SPACING:Regular Wire of Net & Blockage of Cell (M2)
        Actual: 0.1 Min: 0.12
        SPACING:Regular Wire of Net & Blockage of Cell (M3)
        Actual: 0.1 Min: 0.12

-----------------------------------------------------------------------------------------------
