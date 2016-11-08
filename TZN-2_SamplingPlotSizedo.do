*-------------------------------------------------------------*
*-------------------------------------------------------------*
*                     Trees on Farm:                          *
*    Prevalence, Economic Contribution, and                   *
*   Determinants of Trees on Farms across Sub-Saharan Africa  *
*                                                             *
*             https://treesonfarm.github.io                   *
*-------------------------------------------------------------*
*   Miller, D.; Muñoz-Mora, J.C. and Christiaense, L.         *
*                                                             *
*                     Nov 2016                                *
*                                                             *
*             World Bank and PROFOR                           *
*-------------------------------------------------------------*
*                   Replication Codes                         *
*-------------------------------------------------------------*
*-------------------------------------------------------------*


* ------------------------------------------------------------ *
* --- PLOT SIZE AND HH WITH PLOTS   ---- *
* ------------------------------------------------------------ *

  *-- 1. Open and append the data
  
    use "$path_data/TZN/2010-11/AG_SEC2A.dta", clear
    append using "$path_data/TZN/2010-11/AG_SEC2B.dta"

    gen area_farm=ag2a_09
    replace area_farm=ag2b_20 if area_farm==.
    replace area_farm=ag2a_04 if area_farm==.
    replace area_farm=ag2b_15 if area_farm==.

  *-- 2. Append information from the two seasons
    drop if area_farm==.
    replace area_farm=area_farm*0.405
    keep y2_hhid plotnum area_farm 

    * Information for Long Rainy (Season 1)
    merge 1:1 y2_hhid plotnum using "$path_data/TZN/2010-11/AG_SEC3A.dta", keepusing(ag3a_03) nogenerate

    * Information for Short Rainy (Season 2)
    merge 1:1 y2_hhid plotnum using "$path_data/TZN/2010-11/AG_SEC3B.dta", keepusing(ag3b_03) nogenerate

  *-- 3. Plot Use
    rename ag3a_03 plot_use1
    rename ag3b_03 plot_use2
    replace plot_use2=plot_use1 if plot_use2==.

    reshape long plot_use, i(y2_hhid plotnum) j(season 1 2)

    drop if (plotnum=="V1"|plotnum=="V2") & season==1


  *-- 4. Merge information for crops

    merge 1:1 y2_hhid plotnum season using "$path_work/TZN/0_CropsClassification.dta", nogenerate keep(master matched)


     foreach i in n_parcels_Tree_Fruit n_parcels_NA n_parcels_Plant n_parcels_Tree_Agri n_parcels_Tree_wood {
        replace `i'=(`i'>0 & `i'!=.)
      }

  *-- 5. Fixing information For Inter-cropping and 

      * Those non-cultivated plots with forest
      replace  n_parcels_Tree_wood=n_parcels_Tree_wood+1 if plot_use==5

      foreach i in  _Tree_Fruit _NA _Plant _Tree_Agri _Tree_wood {
        gen inter_n`i'=inter_crop*n_parcels`i'
      }

  *-- 6. Adding HH information

   gen t_area_pre_trees=area_farm if n_parcels_Tree_Fruit!=0|n_parcels_Tree_Agri!=0|n_parcels_Tree_wood!=0
    replace t_area_pre_trees=0 if t_area_pre_trees==.

    foreach i in _Tree_Fruit _Tree_Agri _Tree_wood {
      gen t_area_pre`i'=area_farm if n_parcels`i'>0
      replace t_area_pre`i'=0 if t_area_pre`i'==.
    }

    gen x=1
    collapse (sum) t_area_*  n_parcels_*  t_n_trees_*  farm_size=area_farm n_plots=x inter_n* (max)  inter_crop, by(y2_hhid season)

    *Merge information  crops

    merge n:1 y2_hhid using "$path_data/TZN/2010-11/HH_SEC_A.dta", keepusing(y2_weight y2_rural clusterid strataid region district) 

    save "$path_work/TZN/1_Plot-Crop_Information.dta", replace




