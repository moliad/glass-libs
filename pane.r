REBOL [
	; -- Core Header attributes --
	title: "Glass Pane"
	file: %pane.r
	version: 1.0.1
	date: 2013-12-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "A Clipping pane frame."
	web: http://www.revault.org/modules/pane.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'pane
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/pane.r

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
		the pane is a very special frame which is used internally by the scroll-frame (eventually others).  
		
		it allows one to use a sub-layout and offset the origin, somewhat like scrolling a face.  
		it renders the raster for you and has a few aspects which are used by the event handlers to resolve 
		the offset and reset it locally to the sub layout.
		
		as such its pretty much an "internal" style which is meant to work around a limitation in AGG in which 
		clipping cannot be applied hierarchically and isn't subject to the current transform matrix either.
	}
	;-  \ documentation
]





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
		dirty*: dirty
		formulate
	]
	sillica-lib: sl: slim/open/expose 'sillica none [
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
	

	
	;--------------------------------------------------------
	;-   
	;- !PANE[ ]
	!pane: make frame-lib/!frame [
	
		;-    aspects[ ]
		aspects: make aspects [
			;-        color:
			; the bg should be opaque, because Draw doesn't have pre-multiplied compositing.
			;
			; this breaks up edges when trying to use pre-rendered anti-aliased images.
			;
			; in certain circumstances, you may want to change the bg color to something different.
			;color: 0.0.0.255 ;theme-bg-color
			color: theme-bg-color
			
			;-        h-offset:
			h-offset: none
			
			;-        v-offset:
			v-offset: none
			
			;-        backplane-clr:
			; usually you don't need to touch this.
			backplane-clr: none ;0.0.0.255
			
			;--------------------------
			;-         backplane-draw-setup:
			;
			; this is linked in the backplane rasterizer to setup the rendering
			;
			; by default we just add an anti-aliasing instruction!
			;--------------------------
			backplane-draw-setup: [anti-alias #[false]]

		]
		
		
		;-    material[ ]
		material: make material [
			;-        raster:
			raster: none
			
			;-        backplane:
			backplane: none
			
			
			;-        translation:
			translation: 0x0
			
			
		]


		;-    spacing-on-collect:
		; when collecting marbles, automatically set their offset to this value
		; in groups, usually you want content to be juxtaposed.
		spacing-on-collect: 5x5
		
		
		;-    layout-method:
		; most groups are horizontal
		layout-method: 'row

		
		
		;-    view-face:
		;
		; the face we use to render the image with.
		view-face: none


		;-    collect-in-frame:
		;
		; !pane uses the optional collection management, where marbles are collected in another
		; frame. 
		;
		; the other frame does all the layout, and we simply use its results and render them.
		; 
		; it is set to none at the moment, but it will later be filled with the frame in which 
		; we collect the layout.
		; 
		; any call to collect(), using the normal api, will put the marbles in this subframe rather than
		; directly within ourself.
		collect-in-frame: none
		

		;-    rasterizer:
		;
		; the node which renders the pane-frame as an image.
		rasterizer: none
		
		
		;-    pixel-map:
		;
		; the node which renders the pane's back-plane as an image.
		;pixel-map: none
		
		
		
		;-    valve []
		valve: make valve [

			type: '!marble


			;-        style-name:
			style-name: 'pane
		

			;-        fg-glob-class:
			; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
			fg-glob-class: none

			;-        bg-glob-class:
			; class used to allocate and link a glob drawn BEHIND the marble collection
			bg-glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair (random 200x200)
						dimension !pair (300x300)
						color !color
						;border-color  !color (random white)
						; uncomment to debug
;						clip-region !block ([0x0 1000x1000])
;						min-dimension !pair
;						content-dimension !pair
;						content-min-dimension !pair
						backplane !any
						raster !any
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						position backplane 
						[
							image (data/position=) (data/backplane=)
						
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						
						; FG LAYER
						position raster dimension  ;color border-color
						;------
						; uncomment following for debugging
						;
						;   min-dimension content-dimension content-min-dimension
						;------
						[
							; here we restore our parent's clip region  :-)
							;clip (data/parent-clip-region=)
							
							image (data/position=) (data/raster=)
							
							
							;------
							; uncomment for debugging purposes.
							;	line-width 1
							;	pen blue 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/content-dimension=)
							;	pen red 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/dimension=)
							;	pen black 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/min-dimension=)
							;	pen white 
							;	fill-pen (0.0.0.129 + data/color=)
							;	box (data/position=) (data/position= + data/content-min-dimension=)
							;------
						
						]
						
						
						; controls layer
						;[]
						
						
						; overlay 
						;[]
					]
				]
			]

			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				pane
				/local mtrl
			][
				vin [{materialize()}]
				mtrl: pane/material 
				pane/rasterizer: liquify* glob-lib/!rasterizer
				mtrl/raster: pane/rasterizer
				
				mtrl/backplane: liquify* glob-lib/!rasterizer
				
				
				pane/view-face: make sl/empty-face [pane: copy []]
				mtrl/translation: liquify* epoxy-lib/!to-pair


				; link up vertical and horizontal offset aspects.
				; note that if the application overides this, fasten is not performed, so the 
				; app setup will not be reset.
				link* mtrl/translation reduce [
					pane/aspects/h-offset
					pane/aspects/v-offset
				]

				vout
			]
			
			

			;-----------------
			;-        pre-specify()
			;-----------------
			pre-specify: func [
				pane [object!]
				stylesheet [block!]
			][
				vin [{pane/pre-specify()}]
				unless pane/collect-in-frame [
					vprint "column allocating"
					pane/collect-in-frame: sl/alloc-marble/using 'column compose [
						layout-method: (pane/layout-method)
						tight
					] stylesheet
					
					
					v?? pane/collect-in-frame/sid
					
					pane/collect-in-frame/material: make pane/collect-in-frame/material [
						translation: liquify*/link !plug pane/material/position
					]
					
					vprint "column allocated"
					fill* pane/collect-in-frame/aspects/offset 0x0
					
					
					; this is a hack which allows use to go up the frame tree, but remember that the pane's collection
					; DOESN'T include the collect-in-frame directly
					pane/collect-in-frame/frame: pane

					
				]
				vout
			]
			
			;-----------------
			;-        post-specify()
			;-----------------
			post-specify: func [
				pane [object!]
				stylesheet [block!]
			][
				vin [{pane/post-specify()}]
				vprobe content* pane/collect-in-frame/material/dimension
				vprobe content* pane/material/content-dimension
				vprobe content* pane/collect-in-frame/material/content-dimension
				vprobe content* pane/collect-in-frame/material/origin
				vprobe content* pane/aspects/color
				vout
				pane
			]
			
			;-----------------
			;-        fasten()
			; this is a style-specific fastening extension.
			;
			; here we will link up the collect-in-frame with pane values,
			; and will link the raster to pane's glob.
			;
			; we also setup translation so it can be calculated by event mechanism.
			;-----------------
			fasten: func [
				pane
				/local rst cif img mtrl cmtrl bkpln
			][
				vin [{pane/fasten()}]
				vprobe content* pane/collect-in-frame/material/dimension
				vprobe content* pane/material/content-dimension
				vprobe content* pane/collect-in-frame/material/content-dimension
				vprobe content* pane/collect-in-frame/material/origin
				vprobe content* pane/aspects/color
				
				
				rst: pane/rasterizer
				cif: pane/collect-in-frame
				mtrl: pane/material
				cmtrl: cif/material
				bkpln: mtrl/backplane
				
				cif/valve/gl-fasten cif
				
				; mutate collect-in-frame and assign its dimension...
				cmtrl/dimension/valve: epoxy-lib/!pair-max/valve
				
				link*/reset  cmtrl/dimension reduce [
					mtrl/dimension
					cmtrl/min-dimension
				]
				
				; inherit collection-related material from c-i-f
				link*/reset mtrl/min-dimension cmtrl/min-dimension
				link*/reset mtrl/fill-weight cmtrl/fill-weight
				link*/reset mtrl/fill-accumulation cmtrl/fill-accumulation
				
				; link up raster
				link*/reset rst reduce [
					mtrl/dimension
					mtrl/translation
					pane/aspects/color
					pane/collect-in-frame/glob/layers/2
				]
				
				; link up backplane
				link*/reset bkpln reduce [
					mtrl/dimension
					mtrl/translation
					pane/aspects/color
					pane/aspects/backplane-draw-setup ; makes the backplane aliased! 
					pane/collect-in-frame/glob/layers/1
				]
				
				vout
			]
			
			
			
		]
	]
]
