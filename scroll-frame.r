REBOL [
	; -- Core Header attributes --
	title: "iii"
	file: %scroll-frame.r
	version: 1.0.1
	date: 2013-12-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {A frame with an inner frame which you can slide around.}
	web: http://www.revault.org/modules/scroll-frame.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'scroll-frame
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/scroll-frame.r

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
		v1.0.1 - 2013-12-17
			-fixed header information which was still using old MIT license and other deprecated fields.
			-frame-color aspect replaced to border-color
	}
	;-  \ history

	;-  / documentation
	documentation: {
		This is basically a group with a custom layout mechanism.
		
		the inner-frame can be scrolled and its data is NOT clipped.
	}
	;-  \ documentation
]




;- SLIM/REGISTER
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
		process*: --process
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

	
	frame-lib: slim/open 'frame none
	group-lib: slim/open 'group none
	
	
	
	;--------------------------------------------------------
	;-   
	;- !SCROLL-FRAME[ ]
	!scroll-frame: make group-lib/!group [
		;-    aspects[ ]
		aspects: make aspects [
		
			;-        scroller-sizes:
			scroller-sizes: 20x20
			
		]
		
		
		;-    material[ ]
		material: make material [
		
			;-        v-offset:
			v-offset: none
			
			
			;-        h-offset:
			h-offset: none
			
			
			;-        min-dimension:
			min-dimension: 100x100
			
			
			;-        fill-weight:
			; fill up / compress extra space in either direction (independent), but don't initiate resising
			;
			; frames inherit & accumulate these values, marbles supply them.
			fill-weight: 1x1
			
			
			;-        border-size:
			border-size: 0x0
			
			
			; <TO DO> turn this into a bridge so we can set via scrollers or directly using a pair, here.
			;-        inner-offset:
			inner-offset: 0x0
			
			;-        v-max:
			v-max: none
			
			;-        v-visible:
			v-visible: none
			
			;-        h-max:
			h-max: none
			
			;-        h-visible:
			h-visible: none
			
			
		]

		;-    spacing-on-collect:
		; when collecting marbles, automatically set their offset to this value
		; in groups, usually you want content to be juxtaposed.
		spacing-on-collect: 0x0
		
		
		
		;-    layout-method:
		; most groups are horizontal
		layout-method: 'column
		
		
		;-    inner-frame:
		inner-frame: none
		
		;-    v-scroller:
		v-scroller: none
		
		;-    h-scroller:
		h-scroller: none
		
		;-    temp-label:
		;temp-label: none
		
		
		;-    content-specification:
		content-specification: [
			inner-frame: pane
			
			v-scroller: scroller with [fill* material/orientation 'vertical]
			
			h-scroller: scroller with [fill* material/orientation 'horizontal]
			
			;temp-label: title "RR"
		]
		
		
		
		;-    valve []
		valve: make valve [

			type: '!marble


			;-        style-name:
			style-name: 'scroll-frame
		

			;-        bg-glob-class:
			; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
			bg-glob-class: none


			;-        fg-glob-class:
			; class used to allocate and link a glob drawn IN FRONT OF the marble collection
			;
			; windows use this to create an input blocker, for example.
;			-fg-glob-class: make !glob [
;				valve: make valve [
;					;-            glob/input-spec:
;					input-spec: [
;						; list of inputs to generate automatically on setup  these will be stored within the instance under input
;						position !pair (random 200x200)
;						dimension !pair (300x300)
;						disable? !bool
;					]
;					
;					;-            glob/gel-spec:
;					gel-spec: [
;						; event backplane
;						disable? ;position dimension
;						[
;;							(either data/disable?= [
;;								compose [
;;									pen none
;;									fill-pen (white) ; erases backplane.
;;									box  (data/position=) (data/position= + data/dimension= - 1x1)
;;								]
;;								][[]]
;;							)
;						]
;						
;						; bg layer (ex: shadows, textures)
;						; keep in mind... this can be switched off for greater performance
;						;[]
;						
;						; fg layer
;						; position dimension color border-color clip-region parent-clip-region
;						disable? position dimension
;						[
;							; here we restore our parent's clip region  :-)
;							;clip (data/parent-clip-region=)
;							
;;							(
;;								either data/disable?= [
;;									compose [
;;										pen none
;;										fill-pen (theme-bg-color + 0.0.0.100)
;;										box  (data/position=) (data/position= + data/dimension= - 1x1)
;;									]
;;								][
;;									[]
;;								]
;;							)
;;							
;							;pen red
;							line-width 2
;							;line-pattern 10 10
;							;
;							fill-pen none
;							box (data/position=) (data/position= + data/dimension=)
;							;(prim-bevel data/position= data/dimension=  white * .75 0.2 3)
;							;(prim-X data/position= data/dimension=  (data/color= * 1.1) 10)
;			
;						]
;						
;						; controls layer
;						;[]
;						
;						
;						; overlay 
;						;[]
;					]
;				]
;			]
;

			
			

			;-----------------
			;-        group-specify()
			;-----------------
			group-specify: func [
				group [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				/local data
			][
				vin [{glass/!} uppercase to-string group/valve/style-name {[} group/sid {]/group-specify()}]
				parse spec [
					any [
						here:
						set data tuple! (
							vprint "group background COLOR!" 
							set-aspect group 'color data
						) |
						set data pair! (
							vprint "group BORDER SIZE!" 
							fill* group/material/min-dimension data
						) |
						set data block! (
							vprint "setting PANE CONTENT"
							vprobe data
							gl/layout/within/using (bind/copy data group) group/inner-frame stylesheet
						)
						|
						skip (vprint "->")
					]
				]
				vout
				group
			]
			



			
			;-----------------
			;-        gl-materialize()
			;
			; see !marble for details
			;-----------------
;			gl-materialize: func [
;				frame [object!]
;			][
;				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-materialize()}]
;				; manage relative positioning
;				;if relative-marble? frame [
;					frame/material/position: liquify*/fill epoxy-lib/!junction frame/material/position
;					;link* frame/material/position frame/aspects/offset
;				;]
;
;				frame/material/origin: liquify*/fill !plug frame/material/origin
;				frame/material/dimension: liquify*/fill !dim-plug frame/material/dimension
;				frame/material/content-dimension: liquify*/fill !plug frame/material/content-dimension
;				frame/material/min-dimension: liquify*/fill !plug frame/material/min-dimension
;				frame/material/content-min-dimension: liquify*/fill !plug frame/material/content-min-dimension
;				
;				
;				; manage resizing
;				frame/material/fill-weight: liquify*/fill !plug frame/material/fill-weight
;				frame/material/fill-accumulation: liquify*/fill !plug frame/material/fill-accumulation
;				frame/material/stretch: liquify*/fill !plug frame/material/stretch
;				frame/material/content-spacing: liquify*/fill !plug 0x0
;				frame/material/border-size: liquify*/fill !plug frame/material/border-size
;				
;				; this controls where our PARENT can draw we link to it, cause we restore it after our marbles 
;				; have done their stuff.   We also need it to resolve our own clip-region
;				; 
;				; clip regions are stored as a block containing two pairs
;				;marble/parent-clip-region: liquify* !plug
;				
;				
;				; this controls where WE can draw
;				frame/material/clip-region: liquify* epoxy-lib/!box-intersection
;				;link* frame/material/clip-region frame/material/position
;				;link* frame/material/clip-region frame/material/dimension
;				
;				frame/material/parent-clip-region: liquify* !plug 
;				
;				; our link itself after.
;				;marble/material/origin: liquify*/link epoxy/!fast-add marble/material/position
;				
;
;
;				
;				; this is meant for styles to setup their specific materials.
;				;marble/valve/setup-materials marble
;				
;				vout
;			]
			
			
			;-        !dim-plug:
			!dim-plug: process* 'dim-plug [][
				vin "DIM-plug()"
				vprint "======================================="
				vprint data
				vout
				plug/liquid: any [pick data 1 200x200]
			]
			
	

			;-----------------
			;-        !place-at-edge: []
			;
			; this is a purpose-built positioner for scrollers
			;
			; inputs:
			;    frame-position
			;    frame-dimension
			;    edge
			;    marble-min-size: based on edge, we will use x or y value.
			;-----------------
			!place-at-edge: process* '!place-at-edge [
				position dimension edge min-size
			][
				;vin [{!place-at-edge/process}]
				
				position: pick data 1
				dimension: pick data 2
				edge: pick data 3
				min-size: 1x1 * pick data 4 ; can be a width
				
			
				
				plug/liquid: switch/default edge [
					; synonym for bottom
					horizontal [
						position + ( dimension - min-size * 0x1) ;- 0x1
					]
					; synonym for right
					vertical [
						position + ( dimension - min-size * 1x0) ;- 1x0
					]
				][0x0]
				
				;vout
			]
			
			;-----------------
			;-        !dimension-at-edge: []
			;
			; this is a purpose-built positioner for scrollers
			;
			; inputs:
			;    frame-position
			;    frame-dimension
			;    edge
			;    marble-min-size: based on edge, we will use x or y value.
			;-----------------
			!dimension-at-edge: process* '!dimension-at-edge [
				position dimension edge min-size
			][
				;vin [{!dimension-at-edge/process}]
				
				position: pick data 1
				dimension: pick data 2
				edge: pick data 3
				min-size: 1x1 * pick data 4 ; can be a width
				
;			    v?? position
;			    v?? dimension
;			    v?? edge
;			    v?? min-size
;			    
				
				plug/liquid: switch/default edge [
					; synonym for bottom
					horizontal [
						( dimension * 1x0) + (min-size * -1x1)
					]
					; synonym for right
					vertical [
						( dimension * 0x1) + (min-size * 1x-1)
					]
				][0x0]
				
				
				;vout
			]
			
			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				frame
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/materialize()}]
				frame/material/inner-offset: liquify*/fill !plug frame/material/inner-offset
				frame/material/v-max: liquify* epoxy-lib/!y-from-pair
				frame/material/v-visible: liquify* epoxy-lib/!y-from-pair
				frame/material/h-max: liquify* epoxy-lib/!x-from-pair
				frame/material/h-visible: liquify* epoxy-lib/!x-from-pair
				vout
			]
			
			
			
			;-----------------
			;-        gl-fasten()
			;-----------------
			gl-fasten: func [
				frame
				/local mtrl aspects
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-fasten()}]
				
				mtrl: frame/material
				aspects: frame/aspects
				
				
				; mutate scrollers
				frame/v-scroller/material/position/valve: !place-at-edge/valve
				frame/v-scroller/material/dimension/valve: !dimension-at-edge/valve
				frame/h-scroller/material/position/valve: !place-at-edge/valve
				frame/h-scroller/material/dimension/valve: !dimension-at-edge/valve
				
				; mutate inner-frame
				;frame/inner-frame/material/dimension/valve: epoxy-lib/!pair-max/valve
				
				; mutate ourself
				mtrl/content-dimension/valve: epoxy-lib/!pair-subtract/valve
				mtrl/origin/valve: epoxy-lib/!pair-add/valve
				mtrl/inner-offset/valve: epoxy-lib/!negated-integers-to-pair/valve


				; allocate borders around ourself.
				link*/reset mtrl/content-dimension reduce [
					mtrl/dimension
					mtrl/border-size
					mtrl/border-size
					aspects/scroller-sizes
				]
				
				
				; setup our origin
				link*/reset mtrl/origin reduce [mtrl/position mtrl/border-size]
				


				; position scrollbars
				link*/reset frame/v-scroller/material/position reduce [
					mtrl/position
					mtrl/dimension 
					frame/v-scroller/material/orientation
					aspects/scroller-sizes
				]
				link*/reset frame/h-scroller/material/position reduce [
					mtrl/position
					mtrl/dimension 
					frame/h-scroller/material/orientation
					aspects/scroller-sizes
				]

				; dimension scrollbars
				link*/reset frame/v-scroller/material/dimension reduce [
					mtrl/position
					mtrl/dimension 
					frame/v-scroller/material/orientation
					aspects/scroller-sizes
				]
				link*/reset frame/h-scroller/material/dimension reduce [
					mtrl/position
					mtrl/dimension 
					frame/h-scroller/material/orientation
					aspects/scroller-sizes
				]

				; position content-frame
				link*/reset frame/inner-frame/material/position mtrl/origin
				
				; dimension content-frame
				link*/reset frame/inner-frame/material/dimension reduce [mtrl/content-dimension frame/inner-frame/material/min-dimension]

				;fill* frame/inner-frame/material/dimension 400x200

				; setup scroller ranges
				fill* frame/v-scroller/aspects/minimum 0
				link*/reset mtrl/v-max frame/inner-frame/material/min-dimension
				link*/reset frame/v-scroller/aspects/maximum mtrl/v-max
				
				link*/reset mtrl/v-visible mtrl/content-dimension
				link*/reset frame/v-scroller/aspects/visible mtrl/v-visible

				fill* frame/h-scroller/aspects/minimum 0
				link*/reset mtrl/h-max frame/inner-frame/material/min-dimension
				link*/reset frame/h-scroller/aspects/maximum mtrl/h-max
				
				link*/reset mtrl/h-visible mtrl/content-dimension
				link*/reset frame/h-scroller/aspects/visible mtrl/h-visible
;
;
;				; link offset to scrollbars
				link*/reset mtrl/inner-offset reduce [
					frame/h-scroller/aspects/value
					frame/v-scroller/aspects/value
				]
;
;				;fill* frame/temp-label/material/position 40x20
;				;link*/reset frame/temp-label/aspects/label mtrl/origin
;				
				link*/reset frame/inner-frame/material/translation mtrl/inner-offset

;				frame/valve/fasten frame

				fill* frame/h-scroller/aspects/value 0
				fill* frame/v-scroller/aspects/value 0

				vout
			]
			
			
		]
	]
]
