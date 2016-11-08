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
* --- DATA ON PLANTING - SECTION 4 - AGRICULTURAL MODULE  ---- *
* ------------------------------------------------------------ *
* Data was collected only on one visit
 **** Fruits Trees (AG_SEC6A.dta) + Permanent Crops (AG_SEC6B.dta)

  *----------------------------
  *  All Crops together
  *----------------------------

    *--- 1 - Open DataSet - All Data Sets Together
        * Start with Fruit Crops
        use "$path_data/TZN/2010-11/AG_SEC6A.dta", clear
        rename ag6a_02 t_n_trees
        * Append Permanent Crops
        append using "$path_data/TZN/2010-11/AG_SEC6B.dta"
        replace t_n_trees=ag6b_02 if t_n_trees==.
        gen d_crop=1
         * Append Transitory - Long rainy Season 
        append using "$path_data/TZN/2010-11/AG_SEC4A.dta"
        replace d_crop=2 if d_crop==.
          * Append Transitory - Long rainy Season 
        append using "$path_data/TZN/2010-11/AG_SEC4B.dta"
        replace d_crop=3 if d_crop==.

        * Labels for the differnent crops
        label def d_crop 1 "Permanent" 2 "First Season" 3 "Second Season"
        label val d_crop d_crop

    *---  2 - Only the data we are inserted

      keep y2_hhid plotnum zaocode d_crop t_n_trees
      drop if zaocode==.
      rename zaocode crop_id


    *---  3 - Include our crop classification
      include "$path_work/do-files/TZN-CropClassification.do"


    *---  4 - Collapse information
        gen x=1
        collapse (sum) n_parcels=x t_n_trees ,by( y2_hhid plotnum d_crop tree_type)

    *---  5 - Information per season

      reshape long h, i(y2_hhid plotnum d_crop tree_typ) j(season 1 2)
        drop h
        drop if d_crop==2 & season==2
        drop if d_crop==3 & season==1
        drop d_crop

      collapse (sum) n_parcels t_n_trees, by(y2_hhid plotnum season tree_type)

    *-- 6. We identify whether the Parcel has more than one crop (i.e. Inter-cropped)

            bys y2_hhid plotnum season: gen n_crops_plot=_N
            gen inter_crop=(n_crops_plot>1 & n_crops_plot!=.)
            drop n_crops_plot

    *-- 7. Reshape the data for the new crops system

            encode tree_type, gen(type_crop)
                * 1 Fruit Tree
                * 2 NA
                * 3 Plant/Herb/Grass/Roots
                * 4 Tree Cash Crops
                * 5 Trees for timber and fuel-wood

            drop tree_type
            order y2_hhid plotnum season type_crop
            reshape wide n_parcels t_n_trees , i(y2_hhid plotnum season) j(type_crop)
  
    *--- 8. Rename Variables 
            global names "Tree_Fruit NA  Plant  Tree_Agri  Tree_wood "
            local number "1 2 3 4 5 "
            
            local i=1
            foreach y of global names {
                local name: word `i' of `number'
                foreach h in n_parcels t_n_trees {
                rename `h'`name' `h'_`y'
                replace `h'_`y'=0 if `h'_`y'==.
                }
                local i=`i'+1
            }
    

    save "$path_work/TZN/0_CropsClassification.dta", replace

  