REBOL [
	; -- Core Header attributes --
	title: "Glass requestor"
	file: %requestor.r
	version: 1.0.1
	date: 2013-12-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {Default requestor group, basis for all other requestors.}
	web: http://www.revault.org/modules/requestor.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'requestor
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/requestor.r

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
		v1.0.0 - 2013-09-17
			-License changed to Apache v2
			
		v1.0.1 - 2013-12-17
			-frame-color aspect replaced to border-color
	}
	;-  \ history

	;-  / documentation
	documentation: {
		The requestor is a base style which is useful to make (usually) modal requestors quickly.
		
		We rarely use the requestor directly, usually we use the gl/request function and it
		will take care of placing it on the GUI.
		
		The goal of the requestor really is just as a wrapper in which to put message boxes
		and notifications.  how its used  (as an overlay, or window) is not of the requestor's
		concern.
		
		This style is still very basic, in time it will evolve to include title, graphics, shadows
		and such so that making standardized requestors is very easy and uniform.
		
		These things will be set into aspects, so totally accesible and easy to use.
	}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'requestor
;
;--------------------------------------

slim/register [

	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob]
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
		detach*: detach
	]
	sillica-lib: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]

	
	group-lib: slim/open 'group none
	

	
	;--------------------------------------------------------
	;-   
	;- !REQUESTOR[ ]
	!requestor: make group-lib/!group [
	
		;-    aspects[ ]
		aspects: make aspects [
			color: none ; white * 0.3
		]
		
		
		;-    material[ ]
		material: make material [
			border-size: 0x0
		]


		;-    viewport:
		; used by event engine, for modality control and auto hiding.
		;
		; we use this to track on which viewport this requestor is currently displayed.
		; if none, we aren't currently visible.
		;
		; the viewport is stored so requestor can be removed autonomously later.
		viewport: none
		
	
		
		;-    content-specification:
		; this stores the spec block we execute on setup.
		;
		; it is handled normally by frame.
		;
		; note that the dialect for the group itself, is completely redefined for each group.
		content-specification: compose/deep [
			column tight [
				column  (theme-frame-color) (theme-frame-color) corner 0 [
					;title-bar tight [
						title-bar: requestor-title left "Request" 
					;]
				]
				shadow-hseparator
			]
			column []
		]
		
		;-    title-label:
		title-bar: none
		
		
		
		;-    layout-method:
		layout-method: 'column
		
		
		
		;-    valve []
		valve: make valve [

			type: '!marble


			;-        style-name:
			style-name: 'requestor
		

			;-        bg-glob-class:
			;-        fg-glob-class:
			fg-glob-class: none
			bg-glob-class: make glob-lib/!glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair 
						dimension !pair
						color !color (blue)
						border-color  !color 
						;clip-region !block ([0x0 1000x1000])
						;parent-clip-region !block ([0x0 1000x1000])
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
						 position dimension color border-color ;clip-region parent-clip-region
						[
							(sillica-lib/prim-shadow-box data/position= data/dimension=  5 )
							
							line-width 0
							fill-pen theme-requestor-bg-color
							pen (theme-knob-border-color)
							box (data/position=) (data/position= + data/dimension= - 1x1)
							
							;(sillica-lib/prim-bevel data/position= data/dimension=  any [data/color= theme-bevel-color] 0.5 1)
						]
						
						; controls layer
						;[]
						
					]
				]
			]

			
	
			;-----------------
			;-        group-specify()
			;-----------------
			group-specify: func [
				group [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				/local data column
			][
				vin [{glass/!} uppercase to-string group/valve/style-name {[} group/sid {]/group-specify()}]
				column: group/collection/2
				
				parse spec [
					any [
						set data string! (
							fill* group/title-bar/aspects/label data ;group/collection/1/aspects/label data
						) |
						set data tuple! (
							set-aspect group 'color data
						) |
						set data pair! (
							fill* group/materials/min-dimension data
						) | 
						set data block! (
							column/valve/specify column reduce [data] stylesheet
							column/valve/gl-fasten column
						) |

						skip
					]
				]

				vout
				group
			]
		]
	]
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

