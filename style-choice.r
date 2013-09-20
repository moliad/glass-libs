REBOL [
	; -- Core Header attributes --
	title: "Glass choice pull down"
	file: %style-choice.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {POPUP choice which shows list of items from which to pick.  uses a list style as part of its glob.}
	web: http://www.revault.org/modules/style-choice.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-choice
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-choice.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v1.0.0 - 2013-09-18
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		The style choice is a derivative of the popup specifically implemented as a simple drop-down list-picker.
		
		the items aspect is a bulk, whcih is either filled-in or linked making it very flexible, since
		the data items don't have to be stored and defined within the choice.
	
		The main next feature will be the ability to switch it to a drop-down with a scroller when
		there are too many items to show.
		
		The drop-down should also be positioned automatically within window borders, when that functionality will
		be added to the drop-down style.
	}
	;-  \ documentation
]




slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [ !glob to-color ]
	popup-lib: slim/open 'popup none
	event-lib: slim/open 'event none

	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*:    fill 
		link*:    link
		unlink*:  unlink
		dirty*:   dirty
	]


	sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		prim-knob
		top-half
		bottom-half
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	slim/open/expose 'bulk none [ make-bulk ]

	


	;--------------------------------------------------------
	;-   
	;- !CHOICE[ ]
	!choice: make popup-lib/!popup [
	
		;-    drop-list:
		; stores a reference to our internal drop-list, within fasten.
		drop-list: none
		
		;-    max-size:
		max-size: 20000x300



		;-    Aspects[ ]
		aspects: make aspects [
			;-        label:
			label: "choice"
			
			
			;-        items:
			; items used by drop-down is a bulk. if no label-column: is specified in header,
			; column 1 is assumed.
			;
			; if none, the choice simply doesn't show a selection drop down.
			items: none
			
			
			;-        picked-item:
			; which item is selected in choice.
			;
			; usefull to pipe other labels to it.
			picked-item: none
			
		]
		
		;-    valve[ ]
		valve: make valve [
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'choice  
			
			
			;-        label-font:
			; font used by the gel.
			label-font: theme-knob-font


			;-        overlay-glob-class
			overlay-glob-class: [
				column tight with [
					fill* aspects/color white 
					fill* aspects/frame-color black
					fill* material/border-size 3x3
				][
					droplist with [
						fill* aspects/items make-bulk/records 3 ["one" [] 1 "two" [] 2 "three" [] 3] 
						fill* material/min-dimension 200x100
					]
				]
			]
		
		
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				pos: none
				
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						label-color !color  (random white)
						label !string ("")
						focused? !bool
						hover? !bool
						selected? !bool
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension 
						[
							line-width 1 
							pen none 
							fill-pen (to-color gel/glob/marble/sid) 
							box (data/position=) (data/position= + data/dimension= - 1x1)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color label-color label hover? focused? selected?
						[
							
							(	;draw bg and highlight border?
								any [
									all [ 
										data/hover?= data/selected?= compose [
											; bg color
											pen none
											line-width 0
											fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
											box (data/position= + 1x1) (data/position= + data/dimension= - 1x1) 4
	
											; shine
											pen none
											fill-pen (data/color= * 0.7 + 140.140.140.128)
											box ( top-half  data/position= data/dimension= ) 4
											
											;inner shadow
											pen shadow ; 0.0.0.50
											line-width 2
											fill-pen none
											box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) 4
	
											pen none
											line-width 0
											fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
											box (pos: (data/position= + (data/dimension= * 0x1) - -2x10)) (data/position= + data/dimension= - 2x1) 4
	
											; border
											fill-pen none
											line-width 1
											pen  theme-knob-border-color
											box (data/position= ) (data/position= + data/dimension= - 1x1) 4


										]
									]
									
									; default
									compose [
										(
											prim-knob 
												data/position= 
												data/dimension= - 1x1
												none
												theme-knob-border-color
												'horizontal
												1
												4
										)
									]
								]
							)
							
							(
							either data/hover?= [
								compose [
									line-width 1
									pen none
									fill-pen (theme-glass-color + 0.0.0.220)
									box (data/position= + 3x3) (data/position= + data/dimension= - 3x3) 2
								]
							][[]]
							)							
							line-width 0
							fill-pen none 
							pen (theme-glass-color + 0.0.0.150)
							(sl/prim-arrow (data/position= + (data/dimension= * 1x0) - 10x-4 + ((data/dimension=/y * 0x1 / 2) ) ) 10x9 'bullet 'down)
							
							; label
							pen none
							fill-pen (data/label-color=)
							(prim-label data/label= data/position= + 6x0 data/dimension= data/label-color= theme-small-knob-font 'left)
							
						]
							
						; controls layer
						;[]
						
						; overlay layer
						; like the bg, it may switched off, so don't depend on it.
						;[]
					]
				]
			]
			
			
			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				choice
				/lbl
			][
				vin [{glass/!} uppercase to-string choice/valve/style-name {[} choice/sid {]/fasten()}]
				vprint "FASTEN CHOICE"
				
				choice/drop-list: choice/overlay-glob/collection/1/collection/1
				
				choice/drop-list/controled-by: choice
				
				choice/aspects/items: choice/drop-list/aspects/items
				choice/aspects/picked-item: choice/drop-list/aspects/picked-item
				
				
				link*/reset choice/aspects/label choice/aspects/picked-item
				
				vout
			]
			
			
			
			;-----------------
			;-        specify()
			;
			; parse a specification block during initial layout operation
			;
			; can also be used at run-time to set values in the aspects block directly by the application.
			;
			; but be carefull, as some attributes are very heavy to use like frame sub-marbles, which will 
			; effectively trash their content and rebuild the content again, if used blindly, with the 
			; same spec block over and over.
			;
			; the marble we return IS THE MARBLE USED IN THE LAYOUT
			;
			; so the the spec block can be used to do many wild things, even change the 
			; marble type on the fly!!
			;-----------------
			specify: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				/local data pair-count tuple-count block-count drop-list
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/specify()}]
				drop-list: marble/overlay-glob/collection/1/collection/1
				
				
				pair-count: 0
				tuple-count: 0
				block-count: 0
				parse spec [
					any [
						copy data ['with block!] (
							do bind/copy data/2 marble 

						) | 
						'stiff (
							fill* marble/material/fill-weight 0x0
						) |
						set data tuple! (
							tuple-count: tuple-count + 1
							switch tuple-count [
								1 [set-aspect marble 'label-color data]
								2 [set-aspect marble 'color data]
							]
							
							set-aspect marble 'color data
						) |
						set data pair! (
							pair-count: pair-count + 1
							switch pair-count [
								1 [	fill* marble/material/min-dimension data]
								2 [	set-aspect marble 'offset data ]
							]
						) |
						set data string! (
							fill* drop-list/aspects/picked-item data
						) |
						set data block! (
							block-count: block-count + 1
							switch block-count [
								1 [
									fill* drop-list/aspects/items make-bulk/records 3 data
								]
								2 [
									if object? get in drop-list 'actions [
										drop-list/actions: make drop-list/actions [
											pick-item: make function! [event] bind/copy data drop-list
										]
									]
								]
							]
						) |
						skip 
					]
				]
				vout
				marble
			]			
		]
	]
]
