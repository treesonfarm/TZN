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
* --- DATA ON PRODUCTION - MODULE V - AGRICULTURAL MODULE  ---- *
* ------------------------------------------------------------ *

* Data was collected only on one visit


    * Sells Crops Short (Long Rainy Season)
      use "$path_data/TZN/2010-11/AG_SEC5A.dta", clear
      keep y2_hhid zaocode ag5a_03
        * Short Rainy Season
      merge 1:1 y2_hhid zaocode using "$path_data/TZN/2010-11/AG_SEC5B.dta", keepusing(ag5b_03) nogenerate
        * Fruits
      merge 1:1 y2_hhid zaocode using "$path_data/TZN/2010-11/AG_SEC7A.dta", keepusing(ag7a_04) nogenerate
        * Permanent crops
          * There are some repeated values in this data set, so I will fix this first
            preserve
            use "$path_data/TZN/2010-11/AG_SEC7B.dta", clear
            replace ag7b_04=0 if ag7b_04==.
            collapse (sum)   ag7b_04, by(y2_hhid zaocode)
            save "$path_work/TZN/0_Fix_Sells.dta", replace
            restore

      merge 1:1 y2_hhid zaocode using "$path_work/TZN/0_Fix_Sells.dta", keepusing(ag7b_04) nogenerate

      * Organizing the variables
      foreach i in  ag5a_03 ag5b_03 ag7a_04 ag7b_04 {
        replace `i'=0 if `i'==.
      }

      gen value_sold=ag5a_03+ag5b_03+ag7a_04+ag7b_04

      *---  3 - Include our crop classification
      rename zaocode crop_id
      include "$path_work/do-files/TZN-CropClassification.do"



      * Collapsing the data

      collapse (sum) value_sold, by(y2_hhid tree_type)

    *Merge information for crops

    merge n:1 y2_hhid using "$path_data/TZN/2010-11/HH_SEC_A.dta", keepusing(y2_weight y2_rural clusterid strataid region district) nogenerate
    
    save "$path_work/TZN/0_CropsSells.dta", replace


