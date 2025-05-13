
 package require Tcl 8.4
package require DboTclWriteBasic 16.3.0
package provide capGUIUtils 1.0

namespace eval ::capGUIUtils {
    namespace export capncEnabler
    namespace export capnc
    namespace export capnotnc

    RegisterAction "1.NC" "::capGUIUtils::capncEnabler" "Shift+X" "::capGUIUtils::capnc" "Schematic"
	RegisterAction "2.NOTNC" "::capGUIUtils::capncEnabler" "Shift+Z" "::capGUIUtils::capnotnc" "Schematic"
	RegisterAction "3.Auto Item Num" "::capGUIUtils::capncEnabler" "Shift+Q" "::capGUIUtils::capAutoweihao" "Schematic"

}
proc ::capGUIUtils::capAutoweihao {} {

autoitemnum

   
}
proc autoweihao {obj} {
 
set lReferenceName [DboTclHelper_sMakeCString]

$obj GetReference $lReferenceName 
#得到选定器件的name
set name [DboTclHelper_sGetConstCharPtr $lReferenceName]

set designator [getvalue $obj "Designator"]


if {[info exists ::itemdevice($name)]==1&&$designator!=""} {

	set value [DboTclHelper_sMakeCString $::itemdevice($name)]
	
	$obj SetReference $value
return
}

set num_flag 0
#string index <name> <num>  得到name字符串中的第num个字笿
set flag [string index $name 1]
if {$flag >= 0 && $flag <= 9 || $flag == "?"} {

	set first [string index $name 0]
	set num_flag 1
	
} else { 
	set flag [string index $name 2]
	if {$flag >= 0 && $flag <= 9 || $flag == "?"} {
		set one [string index $name 0]
		set two [string index $name 1]
		set first "$one$two"
		set num_flag 2
	} else {
		set one [string index $name 0]
		set two [string index $name 1]
		set three [string index $name 2]
		set first "$one$two$three"
		set num_flag 3
	}
}

set lStatus [DboState]
#得到Desgin文件	   		   
set lDesign [GetActivePMDesign]
set lNullObj NULL
#array set　<name> <list>  设置字符串name内容为list  
array set weihaonum ""
	#循环Design
	set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_SCHEMATICS] 
	set lView [$lSchematicIter NextView  $lStatus] 
	while { $lView != $lNullObj} { 
		#循环Schematic
		set schematic [DboViewToDboSchematic $lView]
		set lPagesIter [$schematic NewPagesIter $lStatus]  
		set lPage [$lPagesIter NextPage $lStatus]  
		while {$lPage!=$lNullObj} { 
			#循环Page	
			set pPartInstsIter [$lPage NewPartInstsIter $lStatus] 
			set pInst [$pPartInstsIter NextPartInst $lStatus] 
			while {$pInst!=$lNullObj} {
			
				#得到page中元件的名字name2和第一个字符first2
				set lReferenceName [DboTclHelper_sMakeCString]
				$pInst GetReference $lReferenceName 
				set name2 [DboTclHelper_sGetConstCharPtr $lReferenceName]
				set obj1 [DboPartInstToDboPlacedInst $pInst]
				if {$obj1!=$obj} {
			
				
			
				if { $num_flag == 1} {
					set first2 [string index $name2 0] 					
					#如果first2等于first
					if {$first==$first2} {
						#string trim <name> <chars> 把name中的char删除掿
						set weihaonum([string trim $name2 $first]) 1 
					}						
				} else {
					if { $num_flag == 2} {
						set one [string index $name2 0]
						set two [string index $name2 1]
						set first2 "$one$two"
						if {[string compare $first $first2] == 0} {
							#string trim <name> <chars> 把name中的char删除掿
							set weihaonum([string trim $name2 $first]) 1 
						}
					} else {
						set one [string index $name2 0]
						set two [string index $name2 1]
						set three [string index $name2 2]
						set first2 "$one$two$three"
						if {[string compare $first $first2] == 0} {
							#string trim <name> <chars> 把name中的char删除掿
							set weihaonum([string trim $name2 $first]) 1 
						}
					}
				}		 				
					}	  
				set pInst [$pPartInstsIter NextPartInst $lStatus] 
			}
			set lPage [$lPagesIter NextPage $lStatus] 
		} 
		delete_DboSchematicPagesIter $lPagesIter 
		set lView [$lSchematicIter NextView  $lStatus] 
	} 
	delete_DboLibViewsIter $lSchematicIter
	
	#expr是一个运算符
	for {set i 1} {$i<=10000} {set i [expr $i+1]} {
	#info exists <name>  如果上下文中出现过name，则返回1，否则返囿
		if {[info exists weihaonum($i)]==0} {
			#这句此处何用＿
			set lPrpName [DboTclHelper_sMakeCString "Reference"]
			set value [DboTclHelper_sMakeCString "$first$i"]
			break
		}		
	} 
	$obj SetReference $value
     set ::itemdevice($name) "$first$i"
	
	return 
}

proc autoitemnum {} {
catch {
   unset ::itemdevice
   }

array set ::itemdevice ""
    set partnumble [getobj DboPlacedInst]

	for {set j 1} {$j<=$partnumble} {set j [expr $j+1]} {
        set lObject $::typeall($j)
	 
		autoweihao $lObject
	
		
}

   
}
proc getvalue {obj name} {

  set namec [DboTclHelper_sMakeCString $name] 
set valuec [DboTclHelper_sMakeCString] 
$obj GetEffectivePropStringValue $namec $valuec
set value [DboTclHelper_sGetConstCharPtr $valuec]
return $value
}

proc ::capGUIUtils::capnotnc {} {

   set partnumble [getobj DboPlacedInst]
   

	for {set j 1} {$j<=$partnumble} {set j [expr $j+1]} {
        set lObject $::typeall($j)
		NOTNC $lObject
		
}
 
}
proc getallobj {} {  
     set  objnum 0
	 set  typenum 0
	 array set allobj {0 ""}
	 array set ::typeall {0 ""}
     set obj [GetSelectedObjects]
    set alllong [string length $obj]
      for {set j 0} {$j<=[expr $alllong-1]} {set j [expr $j+1]} {
	 
	  set letter [string index  $obj $j]
	  if {$letter==" "} {
	       set objnum [expr $objnum+1]
		   
		   } else {
		  append ::allobj($objnum)  $letter
		  }
		 
		 }
		 

	
	
	return $objnum
 }

#提取所有选择的part皿type类型的器仿
proc getobj {type} {  
   set lStatus [DboState] 
  set lNullObj NULL 
     set  objnum 0
	 set  typenum 0
	 array set allobj {0 ""}
	 array set ::typeall {0 ""}
     set obj [GetSelectedObjects]
    set alllong [string length $obj]
      for {set j 0} {$j<=[expr $alllong-1]} {set j [expr $j+1]} {
	 
	  set letter [string index  $obj $j]
	  if {$letter==" "} {
	       set objnum [expr $objnum+1]
		   
		   } else {
		  append allobj($objnum)  $letter
		  }
		 
		 }
	
for {set j 0} {$j<=[expr $objnum]} {set j [expr $j+1]} { 

	   if {[string first $type $allobj($j)]!=-1 } {
	      set typenum [expr $typenum+1]
	      set ::typeall($typenum) $allobj($j)	      
	   if {$type=="DboPlacedInst"} {
	     
	    if {[getvalue $allobj($j) Designator]!=""} {
		
		#找出所有part器件
		  set weihao [getvalue $allobj($j) Reference]
		
		set lDesign [GetActivePMDesign]






set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_SCHEMATICS] 
 
#get the first schematic view 
 set lView [$lSchematicIter NextView  $lStatus] 
while { $lView != $lNullObj} {
set schematic [DboViewToDboSchematic $lView]
  set lPagesIter [$schematic NewPagesIter $lStatus] 
  #get the first page  
  set lPage [$lPagesIter NextPage $lStatus] 

  while {$lPage!=$lNullObj} { 

set pPartInstsIter [$lPage NewPartInstsIter $lStatus] 
  set pInst [$pPartInstsIter NextPartInst $lStatus] 
  # iterate over all parts 
	  while {$pInst!=$lNullObj} { 
 ########################  


     
    #placeholder: do your processing on $lUProp 
	set cref [DboTclHelper_sMakeCString]
	
 $pInst GetReference $cref
     set ref [DboTclHelper_sGetConstCharPtr $cref]
	 
	set a1 [string range $pInst 0 11]
		set a2 [string range $allobj($j) 0 11]
	if {$ref==$weihao&&$a1!=$a2} {

		      set typenum [expr $typenum+1]
	      set ::typeall($typenum) $pInst
	
	
	
	}
	###############################   
	      
    set pInst [$pPartInstsIter NextPartInst $lStatus] 

  } 
	
	
    #get the next page  
    set lPage [$lPagesIter NextPage $lStatus] 
  } 
  delete_DboSchematicPagesIter $lPagesIter  
  #get the next schematic view 
  set lView [$lSchematicIter NextView  $lStatus] 
} 
delete_DboLibViewsIter $lSchematicIter     








		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		}
	 
	   
	   
	   
	   }
	   
	   
	   }
	  
	}
	
	
	return $typenum
 }
 


proc ::capGUIUtils::capnc {} {

    set partnumble [getobj DboPlacedInst]
	

	for {set j 1} {$j<=$partnumble} {set j [expr $j+1]} {
        set lObject $::typeall($j)
		
		dis $lObject
		
}
 
 
}
 proc ::capGUIUtils::capncEnabler {} {
    set obj [GetSelectedObjects]
	
    set lEnableRotate 1
    # Get the selected objects
    


if {$obj!=""} {
	set lEnableRotate 1
	}
    return $lEnableRotate
}
 
 proc NOTNC {lObject}   {
 set lStatus [DboState] 

set lPropsIter [$lObject NewDisplayPropsIter $lStatus] 
  set lNullObj NULL 
  set asse "Assembly"
 set ve "Value"
  set lPropNameCStr [DboTclHelper_sMakeCString "Assembly"] 
set lPropValueCStr [DboTclHelper_sMakeCString "NC"] 
#get the first display property on the object 
set lDProp [$lPropsIter NextProp $lStatus] 
    set lPrpName [DboTclHelper_sMakeCString "Color"]
   set color [DboTclHelper_sMakeCString "Default"]
    set lStatus [$lObject SetEffectivePropStringValue $lPrpName $color 0]
while {$lDProp !=$lNullObj } { 
   
  #placeholder: do your processing on $lDProp 
   
  #get the name 
  set lName [DboTclHelper_sMakeCString] 
    $lDProp GetName $lName 
  set a [DboTclHelper_sGetConstCharPtr $lName]

    if {$ve==$a} {

    $lDProp SetColor 48
  
   
}

    if {$asse==$a} {


   $lDProp SetDisplayType 0
   
   set lStatus [$lObject DeleteEffectiveProp $lPropNameCStr]

}
  



    #get the next display property on the object 
    set lDProp [$lPropsIter NextProp $lStatus] 
   
  } 
   
	




}





proc dis {lObject} { 
 set lStatus [DboState] 


  set lNullObj NULL 

  set valuestr "Value"
  set asse "Assembly"
  
  set lPropNameCStr [DboTclHelper_sMakeCString "Assembly"] 
set lPropValueCStr [DboTclHelper_sMakeCString "NC"] 
#get the first display property on the object 



set lPropsIter [$lObject NewDisplayPropsIter $lStatus] 
set lDProp [$lPropsIter NextProp $lStatus] 
  set valuetrue 0
while {$lDProp !=$lNullObj } { 
   
  #placeholder: do your processing on $lDProp 
   
  #get the name 
  set lName [DboTclHelper_sMakeCString] 
    $lDProp GetName $lName 
  set a [DboTclHelper_sGetConstCharPtr $lName]

  #get the location 
  set font [DboTclHelper_sMakeLOGFONT]
  set lStatus [$lDProp GetFont 1 $font]
    if {$asse==$a} {


   $lDProp SetDisplayType 0
   
   set lStatus [$lObject DeleteEffectiveProp $lPropNameCStr]

}
  
 
 
  if {$valuestr==$a} {
   
   set valuetrue 1
  
 set lColor [$lDProp GetColor $lStatus] 

  set lLocation [$lDProp GetLocation $lStatus] 
  
$lDProp SetColor 18
  

  set pointx [DboTclHelper_sGetCPointX $lLocation]
  set pointy [DboTclHelper_sGetCPointY $lLocation]

  set newpoint [DboTclHelper_sMakeCPoint $pointx [expr $pointy+10]] 

}




    #get the next display property on the object 
    set lDProp [$lPropsIter NextProp $lStatus] 
   
  } 
   set lPrpName [DboTclHelper_sMakeCString "Color"]
 set color [DboTclHelper_sMakeCString "Default"]
    set lStatus [$lObject SetEffectivePropStringValue $lPrpName $color 0]
   if {$valuetrue==0} {
   set newpoint [DboTclHelper_sMakeCPoint 0 30] 
   }
  

set lDProp [$lObject NewDisplayProp $lStatus $lPropNameCStr $newpoint 0 $font 8]  
$lDProp SetValueString $lPropValueCStr
   
  delete_DboDisplayPropsIter $lPropsIter 

}		   
 