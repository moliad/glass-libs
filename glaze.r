REBOL [
	; -- Core Header attributes --
	title: "Glaze"
	file: %glaze.r
	version: 1.0.2
	date: 2013-11-20
	author: "Maxim Olivier-Adlhoch"
	purpose: "The default stylesheet for GLASS."
	web: http://www.revault.org/modules/glaze.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'glaze
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/glaze.r

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
			-License changed to Apache v2
	
		v1.0.1 - 2013-11-05
			-Added board frame to the stylesheet.
			
		v1.0.2 - 2013-11-20
			-Added CV style
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Glaze is a volatile module right now, since styles come and go, as the whole system
		gets more and more refined.
		
		When the theme engine will be built, glaze will be a central part of that mechanism,
		since many styles are just duplicates with different theme information applied.
		
		Right now all theme information is stored within the 'sillica module, but that will
		all disapear with themes.  I named all theme related values with a 'theme_  prefix
		so they are easy to recognize and find in the various source files later.
		
		Also note that all current theme information is GLOBAL, so be carefull not to use these
		values in your own code, or display corruption can be expected.
		
		This current version of Glaze is completely temporary, but the file will still exist
		later, and you should use it in the same way.  basically just doing a slim/open on it
		and the styles are then used by default by the glass functions.
	}
	;-  \ documentation
]





slim/register [

	;- LIBS

	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
	]
	
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	
	sl: slim/open 'sillica none
	marble: slim/open 'marble none
	frame: slim/open 'frame none
	window: slim/open 'window none
	field: slim/open 'style-field none
	script-editor: slim/open 'style-script-editor none
	button: slim/open 'style-button none
	list: slim/open 'style-list none
	scroller: slim/open 'style-scroller none
	choice: slim/open 'style-choice none
	droplist: slim/open 'style-droplist none
	requestor: slim/open 'requestor  none
	progress: slim/open 'style-progress none
	group-sl: slim/open 'group-scrolled-list none
	group-ed: slim/open/expose 'group-scrolled-editor none [!scroll-edtr: !group-scrolled-editor]
	scroll-frm: slim/open 'scroll-frame none
	pane: slim/open 'pane none
	tlist-lib: slim/open 'style-tree none
	
	toggle: slim/open 'style-toggle none
	icon: slim/open 'style-icon-button none
	image: slim/open 'style-image none
	
	slim/open/expose 'frame-board none [!board]
	
	; manipulators
	slim/open/expose 'style-cv none [!cv]
	
	
	; build the default glass stylesheet
	
	;- FRAMES
	column: make frame/!frame [layout-method: 'column]
	row: make frame/!frame [layout-method: 'row]
	
	sl/collect-style/as make column [aspects: make aspects [frame-color: none]] 'column
	sl/collect-style/as make column [aspects: make aspects []] 'vframe
	sl/collect-style/as make row [aspects: make aspects [frame-color: none] ] 'row
	sl/collect-style/as make row [aspects: make aspects []] 'hframe
	
	sl/collect-style scroll-frm/!scroll-frame
	sl/collect-style pane/!pane
	
	sl/collect-style !board
	
	;-      vcavity
	sl/collect-style/as vcavity: make column [
		;-           aspects[]
		aspects: make aspects [
			;-               color:
			color: none ; default is to use bg
			
			;-               frame-color:
			frame-color: theme-border-color
		]

		;-           material[]
		material: make material [
			;-               border-size:
			border-size: 10x10
		]
		
		

		valve: make valve [
			
			;-----------------
			;-               dialect()
			;-----------------
			dialect: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
			][
				vin [{dialect()}]
				parse spec [
					any [
						'no-border (
							fill* marble/aspects/frame-color none
						)
						
						| skip
					]
				]				vout
			]
		
		
			fg-glob-class: none
			bg-glob-class: make glob-lib/!glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair 
						dimension !pair
						color !color (blue)
						frame-color  !color 
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						 position dimension color frame-color ;clip-region parent-clip-region
						[
							(sl/prim-cavity/all/colors data/position= data/dimension= - 1x1 data/color= data/frame-color=)
			
						]
						
						; controls layer
						;[]
						
					]
				]
			]
		]
	] 'vcavity
	
	sl/collect-style/as make vcavity [ layout-method: 'row ] 'hcavity



	;-      tool-row
	sl/collect-style/as make row [
		;-           aspects[]
		aspects: make aspects [
			;-               color:
			color: none ; default is to use bg
			
			;-               corner:
			corner: 0
			
			
			;-               size:
			size: none
			
			
			;-               frame-color:
			frame-color: theme-border-color
		]

		;-           material[]
		material: make material [
			;-               border-size:
			border-size: 5x5
			
			;-               fill-weight:
			fill-weight: 1x1
			
		]

		valve: make valve [
			fg-glob-class: none
			bg-glob-class: make glob-lib/!glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair 
						dimension !pair
						color !color (blue)
						frame-color  !color
						corner !integer
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						 position dimension color frame-color corner ;clip-region parent-clip-region
						[
							pen none
;							
							line-width 1
							fill-pen linear (data/position= ) 1 (data/dimension=/y) 90 1 1 
								(theme-bg-color * 1.1)
								(theme-bg-color * 1)
								(theme-bg-color * .9)
							box (data/position=) (data/position= + data/dimension= ) (data/corner=)
							
			
						]
						
						; controls layer
						;[]
						
					]
				]
			]
		]
	] 'tool-row


	;-      title-bar
	sl/collect-style/as make row [
		;-           aspects[]
		aspects: make aspects [
			;-               color:
			color: none ; default is to use bg
			
			;-               corner:
			corner: 3
			
			
			;-               size:
			size: none
			
			
			;-               frame-color:
			frame-color: theme-border-color
		]

		;-           material[]
		material: make material [
			;-               border-size:
			border-size: 5x5
			
			;-               fill-weight:
			fill-weight: 1x1
			
		]

		valve: make valve [
			fg-glob-class: none
			bg-glob-class: make glob-lib/!glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair 
						dimension !pair
						color !color (blue)
						frame-color  !color
						corner !integer
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						 position dimension color frame-color corner 
						[
							pen none
							line-width 1
							pen (any [data/frame-color= theme-frame-color])
							fill-pen white
							box (data/position=) (data/position= + data/dimension= - 1x1)
							(sl/prim-glass (data/position=) (data/position= + data/dimension= - 1x1) theme-color 205)
			
						]
						
						; controls layer
						;[]
						
					]
				]
			]
		]
	] 'title-bar


	
	;-      vdrop-frame
	sl/collect-style/as vdrop-frame: make column [
		;-           aspects[]
		aspects: make aspects [
			;-               color:
			color: none ; default is to use bg
			
			;-               frame-color:
			frame-color: theme-border-color
		]

		;-           material[]
		material: make material [
			;-               border-size:
			border-size: 10x10
		]

		valve: make valve [
			fg-glob-class: none
			bg-glob-class: make glob-lib/!glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair 
						dimension !pair
						color !color (blue)
						frame-color  !color 
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color frame-color ;clip-region parent-clip-region
						[
							pen none
							; top shadow
							fill-pen linear (data/position= ) 1 (10) 90 1 1 
								(0.0.0.120) 
								(0.0.0.240) 
								(0.0.0.255 )
							box (data/position=) (data/position= + data/dimension= - 1x1) 3
							
							fill-pen none
							pen (any [data/frame-color= theme-frame-color])
							line-width 1
							box (data/position=) (data/position= + data/dimension= - 1x1) 3
						]
						
						; controls layer
						;[]
						
					]
				]
			]
		]
	] 'vdrop-frame
	
	sl/collect-style/as make vdrop-frame [ layout-method: 'row ] 'hdrop-frame
	
	
	;- LAYOUT CONTROL
	;sl/collect-style marble/!marble
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [label: none ]
		material: make material [fill-weight: 1x1]
	] 'elastic
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [label: none ]
		material: make material [fill-weight: 1x0 min-dimension: 0x0]
	] 'hstretch
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [label: none]
		material: make material [fill-weight: 0x1  min-dimension: 0x0]
	] 'vstretch
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [label: none ]
		material: make material [fill-weight: 0x0 min-dimension: 20x20]
	] 'pad
	
	
	;- SEPARATORS
	;-     shadows
	shadow-separator: sl/collect-style/as make marble/!marble [
		aspects: make aspects [label: none]
		material: make material [fill-weight: 0x0 min-dimension: 3x3 ]


		valve: make valve [
			
			setup-style: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/stylize()}]
				vout
			]
			
			
			glob-class: make glob-class [
			
				valve: make valve [

					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair
						dimension !pair 
					]
					gel-spec: [
						; event backplane
						none
						[]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension
						[
							line-width 1
							pen  (0.0.0.128)
							line  (data/position= + (0x1 * data/dimension= - 0x3)) (data/position= + data/dimension= - 0x3)
							pen (0.0.0.200)
							line  (data/position= + (0x1 * data/dimension= - 0x2)) (data/position= + data/dimension= - 0x2)
							pen (0.0.0.240)
							line  (data/position= + (0x1 * data/dimension= - 0x1)) (data/position= + data/dimension= - 0x1)
						]
					]
				]
			]
		]
	] 'shadow-hseparator

	sl/collect-style/as make shadow-separator [
		valve: make valve [
			glob-class: make glob-class [
				valve: make valve [
					gel-spec: [
						; event backplane
						none
						[]
						
						
						; fg layer
						position dimension
						[
							pen (0.0.0.240)
							line  (data/position= + (0x1 * data/dimension= - 3)) (data/position= + data/dimension= - 0x3)
							pen (0.0.0.200)
							line  (data/position= + (0x1 * data/dimension= - 2)) (data/position= + data/dimension= - 0x2)
							pen (0.0.0.128)
							line  (data/position= + (0x1 * data/dimension= - 1)) (data/position= + data/dimension= - 0x1)
						]
					]
				]
			]
		]
	] 'upshadow-hseparator
		
	
	
	
	;- LABELS
	sl/collect-style/as make marble/!marble [ aspects: make aspects [font: theme-title-font] ] 'Title
	sl/collect-style/as make marble/!marble [ aspects: make aspects [font: theme-subtitle-font] ] 'SubTitle
	sl/collect-style/as make marble/!marble [ aspects: make aspects [font: theme-headline-font] ] 'headline
	sl/collect-style/as make marble/!marble [ aspects: make aspects [font: theme-label-font] ] 'Label
	sl/collect-style/as make marble/!marble [ aspects: make aspects [font: make theme-label-font [bold?: true]] ] 'bold-Label
	auto-lbl: sl/collect-style/as make marble/!marble [
		aspects: make aspects [font: theme-label-font]
		label-auto-resize-aspect: 'automatic
	] 'auto-label
	
	sl/collect-style/as make auto-lbl [
		aspects: make aspects [font: make font [bold?: true]]
	] 'auto-bold-label
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [
			font: theme-title-font
			padding: 3x0
		]
		label-auto-resize-aspect: 'automatic
	] 'auto-title
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [
			font: theme-subtitle-font
			padding: 3x0
		]
		label-auto-resize-aspect: 'automatic
	] 'auto-subtitle
	
	sl/collect-style/as make marble/!marble [
		aspects: make aspects [
			font: theme-requestor-title-font
		]
		label-auto-resize-aspect: 'automatic
	] 'requestor-title
	
	
	
	
	

	;- GAUGES
	sl/collect-style progress/!progress
	
	
	;- IMAGE DISPLAY
	sl/collect-style image/!image

	;- CONTROLS
	sl/collect-style field/!field
	sl/collect-style script-editor/!editor
	sl/collect-style/as make field/!field [material: make material [ min-dimension: 20x25]] 'short-field 
	sl/collect-style scroller/!scroller


	;- BUTTONS
	;-     button
	sl/collect-style button/!button
	sl/collect-style toggle/!toggle
	sl/collect-style icon/!icon
	tool-icon: sl/collect-style/as make icon/!icon [icon-set: 'toolbar] 'tool-icon
	
	sl/collect-style/as make button/!button [aspects: make aspects [font: make font [bold?: false]]] 'thin-button
	sl/collect-style/as make button/!button [aspects: make aspects [font: make font [size: 11 bold?: false]]] 'small-button
	sl/collect-style/as make button/!button [aspects: make aspects [font: make font [size: 9 bold?: false]]] 'tiny-button
	
	
	;-     link-button
	sl/collect-style/as make button/!button [
		
		
		;         label-auto-resize-aspect:
		label-auto-resize-aspect: 'automatic
		
		
		aspects: make aspects [
			label: "link" 
		
			size: -1x-1
			
			font: theme-small-knob-font
			
			padding: 5x2
		]
		
		valve: make valve [
			glob-class: make glob-class [
			
				valve: make valve [

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
						position dimension color label-color label align hover? focused? selected? padding font
						[
							(
								any [
									all [ data/hover?= data/selected?= compose [
										; bg color
										pen none
										line-width 0
										fill-pen linear (data/position=) 1 (data/dimension=/y) 90 1 1 ( data/color= * 0.6 + 128.128.128) ( data/color= ) (data/color= * 0.7 )
										box (data/position= + 1x1) (data/position= + data/dimension= - 1x1) 4

										; shine
										pen none
										fill-pen (data/color= * 0.7 + 140.140.140.128)
										box ( sl/top-half  data/position= data/dimension= ) 4
										
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
										box (data/position= ) (data/position= + data/dimension= - 1x1) 5

										(
										either data/hover?= [
											compose [
												line-width 1
												pen none
												fill-pen (theme-glass-color + 0.0.0.200)
												;pen theme-knob-border-color
												box (data/position= + 3x3) (data/position= + data/dimension= - 3x3) 2
											]
										][[]]
										)

										]
									]
									
									; default
									all [ data/hover?= compose [
										(
											sl/prim-knob 
												data/position= 
												data/dimension= - 1x1
												data/color=
												theme-knob-border-color
												'horizontal ;data/orientation=
												1
												4
										)
									]]
								]
							)
							line-width 0.5
							pen none ;(data/label-color=)
							fill-pen (data/label-color=)
							; label
							(sl/prim-label/pad data/label= data/position= + 1x0 data/dimension= data/label-color= data/font= data/align= data/padding=)
							
							
							
						]
							
						; controls layer
						;[]
						
						; overlay layer
						; like the bg, it may switched off, so don't depend on it.
						;[]
					]
				]
			]
		]
	] 'link-button
	
	
	sl/collect-style/as make tool-icon [
		aspects: make aspects [
			icon: #check-mark-off 
			engaged-icon: #check-mark-on 
			
			;no-label stiff  
		]
	] 'check-mark
	
	
	;- MANIPULATOR styles
	sl/collect-style !cv
	
	

	;- COMPLEX styles
	sl/collect-style list/!list
	sl/collect-style droplist/!droplist
	
	
	;- POP-UP styles
	sl/collect-style choice/!choice
	
	
	;- GROUP styles
	;sl/collect-style group-field/!group-field
	sl/collect-style group-sl/!scrolled-list
	sl/collect-style !scroll-edtr
	
	
	;- WINDOWS 
	sl/collect-style window/!window
	
	;- REQUESTORS
	sl/collect-style requestor/!requestor
	
	;- TREE LISTS
	sl/collect-style tlist-lib/!tree-list
	
	
	
	;- FUNCTIONS
	
	;-----------------
	;-     styles-von()
	;-----------------
	styles-von: func [
		
	][
		vin [{massive-von()}]
		window/von
		group-sl/von
		list/von
		vout
	]
	
	
]
