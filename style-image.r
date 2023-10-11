REBOL [
	; -- Core Header attributes --
	title: "Glass image marble style"
	file: %style-image.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "A simple style which allows you to display images."
	web: http://www.revault.org/modules/style-image.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-image
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-image.r

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
			-License change to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		The basic image style.
		 
		Its very quickly hacked up but it works.
		
		just fill the image aspect with your loaded image, and it will display in the gui, using the size of image
		as its minimal size by default.
		
		There could be more aspects added which control how the image either scales or resizes, so please speak up 
		if you need more control.   
		
		right now, the image always resizes so as to follow the size of the marble within its frame(s).
		
		if you set it to stiff, it will no longer resize. simple but effective.
		
		if you want more control over the image, you can create yourself some image manipulation nodes and plug
		the manipulated image to the image marble (this is usually the best way to proceed).
		
		the minimum-size is taken from the image by default, but you actually can change it by filling the 
		material/min-size manually *after* the marble is setup by glass.  
		
		everytime you collect an image marble it will again use the automatic min-size, so take care to fill it 
		again in this case (though you should rarely, if ever collect image marbles.. usually you put them into frames).
	}
	;-  \ documentation
]



;- SLIM/REGISTER
slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	
	marble-lib: slim/open 'marble none
	event-lib: slim/open 'event none
	slim/open/expose 'utils-series none [comply]
	
	!plug: liquify*: content*: fill*: link*: unlink*: none
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		[liquify* liquify ] 
		[content* content] 
		[fill* fill] 
		[link* link] 
		[unlink* unlink] 
		[dirty* dirty]
	]
	
	sillica-lib: slim/open/expose 'sillica none [
		prim-label
		inner-box
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]

	
	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;

	;--------------------------------------------------------
	;-   
	;- !IMAGE[ ]
	!image: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
			;-        size:
			size: 10x10
			
			
			;-        image:
			; contains the image to show.
			image: draw 100x100 compose [
				fill-pen (gold * .8) box 0x0 300x300 fill-pen red line-pattern 5 5 pen white black circle 49x49 30
			]
			
			
			;-        label:
			; you may add a label below the image (overlayed)
			label: "image"
			

			;-        label-color:
			label-color: theme-label-color
			
			
			;-        label-shadow-color:
			; a second label printed at 1x1 pixel offset will use this
			; color if its not none.
			label-shadow-color: black
			
			
			;-        font
			font: theme-label-font
			
			;-        text-align:
			; aligned from edge of marble, not edge of image.  this allows you to use padding in order to put text underneath.
			; when combined with align, you will be able to have full control over image location and text.
			text-align: 'bottom
			
			
			;-        keep-aspect?:
			; setup a value to decide how to react to resizing based on source image size
			keep-aspect?: false
			
			;-        sizing-mode:
			; Decide how to react to pane sizing
			; choose from :  stretch, keep-aspect, keep-size (clipped)
			fill-mode: 'keep-aspect
			
			;-        align:
			; not yet implemented
			;
			; use to place the image when sizing-mode setup allows the image can "float" within
			; the space its given.
			align: 'center
			
			;-        fill
			; only usefull 
			; choose from  [auto fill-x fill-y ]
			
			
			;-        padding
			padding: 0x0			
			
			
			;-        border-size:
			border-size: 3
			
			;-        border-style:
			; can only be a color for now
			border-style: theme-border-color
			
			;-        corner:
			corner: 4
		]

		
		;-    Material[]
		material: make material [
		
			;-    fill-weight:
			fill-weight: 1x1
			
		]
		
		
		
		
		
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'image  
			
			
			;-        label-font:
			; font used by the gel.
			;label-font: theme-knob-font
			
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
						image !any
						label-color !color  (random white)
						label-shadow-color
						label !string ("")
						text-align !word
						padding !pair
						font !any
						corner !integer
						border-style !any
						border-size !integer
						align !word
						fill-mode !word
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
						position dimension image label-color label-shadow-color label align 
						text-align padding font corner border-style border-size fill-mode 
						[
							;pen (data/border-style=)
							(
								;print "++++++++++++"
								comply data/image= [ 
									.area: inner-box (data/dimension= - (data/padding= * 2)) data/image=/size 'fit 'start
									.pos-end: data/position= + data/padding= + .area/offset + .area/size
									compose [
										pen none
										fill-pen none
										IMAGE-FILTER bilinear 
										;IMAGE-FILTER nearest  
										image (data/image=) 
										( data/position= + data/padding= + .area/offset ) 
										(.pos-end) 
									]
								]
							)
							fill-pen none
							pen (data/border-style=)
							line-width (data/border-size=)
							box (data/position= + data/padding=) (data/dimension= - 1x1 + data/position= - (data/padding= * 2)) (data/corner=)
							pen none
							
;							(prim-label data/label= (data/position= + data/padding=) (data/dimension=   - data/padding= - data/padding= ) 
;							            data/label-shadow-color= data/font= data/text-align=
;							 )
							( if data/label-shadow-color= [	prim-label data/label= data/position= data/dimension= data/label-shadow-color= data/font= data/text-align= ])
							(if data/label-color= [ prim-label data/label= (data/position= - 1x1) data/dimension= data/label-color= data/font= data/text-align= ])
							
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
			;-        dialect()
			;
			; this uses the exact same interface as specify but is meant for custom marbles to 
			; change the default dialect.
			;
			; note that the default dialect is still executed, so you may want to "undo" what
			; it has done previously.
			;
			;-----------------
			dialect: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				
			][
				vin [{dialect()}]
				color-count: 1
				mtrl: marble/material
				aspects: marble/aspects
				
				;print "!"
				
				parse spec [
					any [
						set data image! (
							fill* aspects/image data
						)
						
						| set data tuple! (
							switch color-count [
								1 [fill* aspects/label-color data]
								2 [fill* aspects/label-shadow-color data]
								3 [fill* aspects/border-style data]
							]
							color-count: color-count + 1
						)
						
						| 'no-shadow (
							fill* aspects/label-shadow-color none
						)
						
						| 'no-border (
							fill* aspects/border-style none
						)
						
						
						; removes all styling and label
						| 'plain (
							fill* aspects/label-color none
							fill* aspects/label-shadow-color none
							fill* aspects/border-size 0
							fill* aspects/border-style none
						)

						
						| 'stiff (
							fill* mtrl/fill-weight 0x0
						) 
						
						| 'stiff-x (
							fill* mtrl/fill-weight 0x1
						) 
						
						| 'stiff-y (
							fill* mtrl/fill-weight 1x0
						) 
						
						; we attempt to link to marbles automatically!!!
						| set data object! (
							if all [
								in data 'valve 
								image? content* data
							][
								link*/reset aspects/image data
							]
						)
						
						| set data integer! (
							fill* aspects/corner data
						)
						
						| set data pair! (
							;print "FOUND IMAGE SIZE"
							;fill* aspects/size data
							fill* mtrl/min-dimension data
						)
						
						| skip
					]
				]

				vout
			]			
			
		]
	]
]
