**
** $Id: prims.spc.rca 1.1 Tue Nov 24 17:21:30 2009 sankum01 Experimental $
** $Source: /syncinc/syncdata/blr-sync1/2647/server_vault/Projects/tsmc/cln65gplus/rf_2p_hde_svt_rvt_hvt/src/config/prims.spc.rca $
**
.global VDDC VSSE VDDP VNW VPW vddc vsse vddp vnw vpw
*** The following 3 models have been added for investigation purposes
*** the models in question will not be used in production. Do not transfer
*** these lines to the public prims.spc file - thank you, Cezary P.
*** .model N_PG228_LLL130E    nmos
*** .model N_PD228_LLL130E    nmos
*** .model P_L228_LLL130E     pmos
************************************************************************
.model n    nmos
.model nd   nmos
.model nh   nmos
.model nl   nmos
.model nreg nmos
.model nhvt nmos
.model nhv  nmos
.model ne   nmos
.model nm   nmos
.model n_x  nmos
.model n_w  nmos
.model n_5v nmos
.model n_5e nmos
.model n_3v nmos
.model n_3e nmos
.model nf   nmos
.model nftk nmos
.model nch  nmos
.model nch_sram  nmos
.model nch3  nmos
.model nv   nmos
.model n_2v   nmos
.model nfet25   nmos
.model nfet33   nmos
.model nfet   nmos
.model nfetmp   nmos
.model ns   nmos
.model mpnfet   nmos
.model hvtnfet  nmos
.model lvtnfet  nmos
.model lvtnfetmp  nmos
.model ncellmp  nmos
.model nenhmp  nmos
.model n_hvt  nmos
.model n_rvt  nmos
.model n_lvt  nmos
.model n_cpd  nmos
.model n_cpg  nmos
.model SRLNFETPD  nmos
.model SRLNFETWL  nmos
.model srmnfetpd nmos
.model srmnfetwl nmos
.model srmpfetpu pmos
***  .model N_12_LLL130E  nmos
***  .model N_12_HSL130E  nmos
***  .model N_PD228_HSL130E  nmos
***  .model N_PG228_HSL130E  nmos
.model PCH_HVT  pmos
.model NCH_HVT  nmos
*.model pch_hvt  pmos
*.model nch_hvt  nmos
.model p_hvt  pmos
.model p_rvt  pmos
.model p_lvt  pmos
.model p_cpu  pmos
***  .model P_12_LLL130E  nmos
***  .model P_12_HSL130E  nmos
***  .model P_L228_HSL130E  pmos
.model pfet   pmos
.model SRLPFETPU   pmos
.model pfetmp   pmos
.model mppfet   pmos
.model hvtpfet  pmos
.model lvtpfet  pmos
.model lvtpfetmp  pmos
.model p_2v   pmos
.model pfet25   pmos
.model pfet33   pmos
.model p    pmos
.model pd    pmos
.model ph    pmos
.model pv    pmos
.model pl   pmos
.model preg pmos
.model phvt pmos
.model phv  pmos
.model pe   pmos
.model pm   pmos
.model p_w  pmos
.model p_x  pmos
.model p_5v pmos
.model p_5e pmos
.model p_3v pmos
.model p_3e pmos
.model pf   pmos
.model pftk pmos
.model pch  pmos
.model pch_sram  pmos
*.model pchpu_sr  pmos
*.model nchpd_sr  nmos
*.model nchpu_sr  nmos
.model pch3  pmos
.model pcell  pmos
.model penhmp  pmos
.model ps  pmos
.model opndres    r
.model r    r
.model c    c
***  .model dion_fusion   d
.model pn_diode   d
.model ns_diode   d
.model DIODENW   d
.model dn   d
.model dipwnd   d
.model ndio d
.model dnh  d
.model dp   d
.model pdio d
.model diop d
.model dv   d
.model db   d
.model np   d
.model d    d
.model d1   d
.model d2   d
.model dx   d
.model dl   d
.model npdio   d
.model XNDIODE d
.model XPDIODE d
.model NPDIOHVT d
.model PNDIOHVT d
.model diodendx d
.model tdndsx d
.model hvtpfetmp pmos
.model hvtnfetmp nmos
.model npg nmos
.model npd nmos
.model ppu pmos
.model P_12_SPL130E pmos
.model N_12_SPL130E nmos
.model DION_SPL130E d
***.model pchpu_dpsr pmos
***.model nchpg_dpsr nmos
***.model nchpd_dpsr nmos
.model PCHPU_SR   pmos
.model NCHPD_SR   nmos
.model NCHPG_SR   nmos
.model PCHPU_DPSR   pmos
.model NCHPD_DPSR   nmos
.model NCHPG_DPSR   nmos
.model PCHPU_DPSR_MAC   pmos
.model NCHPD_DPSR_MAC   nmos
.model NCHPG_DPSR_MAC   nmos
.model PCHPU_HVTDPSR   pmos
.model NCHPD_HVTDPSR   nmos
.model NCHPG_HVTDPSR   nmos
.model npd_hvt   nmos
.model npg_hvt   nmos
.model ppu_hvt   pmos
.model PCHPU_HVTSR   pmos
.model NCHPD_HVTSR   nmos
.model NCHPG_HVTSR   nmos
.model PCHPU_525SR_MAC   pmos
.model NCHPD_525SR_MAC   nmos
.model NCHPG_525SR_MAC   nmos
