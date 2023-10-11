REBOL [
	; -- Core Header attributes --
	title: "Glass frame"
	file: %frame.r
	version: 1.0.2
	date: 2013-12-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {The core marble type which acts as a container for other marbles.}
	web: http://www.revault.org/modules/frame.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'frame
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/frame.r

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
			-License change to Apache v2
			
		v1.0.1 - 2013-11-20
			- frames can now be activated (aspects/active?) so they end up receiving mouse events, just like normal marbles.
			  this allows us to generate control zones which receive inputs (like drag and drop).
	
		v1.0.2 - 2013-12-17
			-Added fill weight scaling allow you to manipulate the relative weight 
			 of one frame wrt another within their parent frame. (scaling to 0 effectively
			 cancels resizing for the frame!)
			-added frame stiffness control in dialect (using fill weight scaling)
			-added manual frame size adjustment
			-replaced frame-color to border-color as to follow the new attribute in the core marble
			
}
	;-  \ history

	;-  / documentation
	documentation: {
		The Frame serves as the root marble for all layout.  Any marble providing layout capabilities
		MUST derive from this one.  you may implement the gl-fasten how-ever you wish, but
		every method and parameter in this object is required by GLASS.
		
		Also, deriving will future-proof your custom layout styles.
		
		This module is EXTENSIVELY commented, so refer to the code when in doubt.
	}
	;-  \ documentation
]




slim/register [
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		[liquify* liquify ] 
		[content* content] 
		[fill* fill] 
		[link* link] 
		[unlink* unlink] 
		[detach* detach] 
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
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection !pair-mult]
	
	marble-lib: slim/open 'marble none
	

	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- !FRAME[ ]
	;
	;-----------------------------------------------------------------------------------------------------------
	
	!frame: make marble-lib/!marble [
	
		;-    aspects[ ]
		aspects: context [
			; managed positioning
			;-        offset:
			;
			; the offset is manipulated by the default fasten code.
			offset: -1x-1
			
			;-        color
			color: none ;theme-bg-color
			
			
			;-        border-color
			border-color: theme-border-color
			
			
			;-        enabled?:
			; when false or none, this will dim the gui and add an input blocker OVER our frame
			; so child collection mouse handling is deactivated.
			;
			; this used to be named 'DISABLE? but it proved ineffective to use a negative value
			; when linking with other controls and data.
			enabled?: #[true]
			
			;-        corner:
			corner: 3
			
			;--------------------------
			;-        active?:
			;
			; when hot, we will receive mouse events
			;
			; by default, frames do not attempt to interact with the event system
			;--------------------------
			active?: false

			;--------------------------
			;-        fill-scale:
			;
			; this multiplies the values of fill-weight and fill-accumulation, allowing you to allocate more
			; space to the frame, or completely disable its resizing (by setting 0 in X AND/OR Y).
			;--------------------------
			fill-scale: 1x1
			
			
			;--------------------------
			;-        dimension-adjust:
			;
			; allows us to adjust the min size manually. this forces us to receive more space
			; which is evenly spread out to children.
			;
			; it may also cause our children to shrink if a negative adjustment is required.
			;
			; this is a manual hack which may cause strange side-effects in some layouts, use with caution.
			;--------------------------
			dimension-adjust: 0x0
			
		]
		
		
		;-    material[ ]
		material: make material [
	
			;-        position:
			; the global coordinates your marble is at 
			; (automatically linked to gui by parent frame).
			position: 0x0 
			
			
			;-        border-size:
			;
			; border-size is used as a containter for now, but eventually, it will be a calculated value,
			; based on margins, padding and edge-size
			border-size: 5x5
			
			
			;-        content-size:
			; depending on marble type, the content-size will mutate into different sizing plugs
			; the most prevalent is the !text-sizing type which expects a !theme plug
			;content-size: none
			
			

			;--------------------------
			;-        content-fill-weight:
			;
			; fill weight of content inside of frame
			;
			; is used to rescale content.
			;
			; frames inherit & accumulate these values, marbles supply them.
			;--------------------------
			content-fill-weight: none
			
			
			
			;-        fill-weight:
			; fill up / compress extra space in either direction (independent), but don't initiate resising
			;
			; this is our own adjusted fill-weight, used for our parents to allocate extra-space
			; to us and our children.
			;
			; this value is basically our content fill-weight multiplied by fill-scale.
			;
			; it allows us to get more extra space than our brethren, or none, if set to 0x0.
			fill-weight: 0x0
			
			
			
			
			;-        fill-accumulation:
			; stores the accumulated fill-weight of this and previous marbles.
			;
			; allows you to identify the fill regions
			;
			;	regions  0  2 3   6  6  8
			;	fill      2  1  3  0  2
			;	gui      |--|-|---|..|--|
			;
			; using regions fills all gaps and any decimal rounding errors are alleviated.
			fill-accumulation: 0x0
			
			
			
			
			
			;-        stretch:
			; marble benefits from extra space, initiates resizing ... preempts fill
			;
			;
			; frames inherit & accumulate these values, marbles supply them.
			stretch: 0x0
			
					
			;-        dimension:
			; computed size, setup by parent frame, includes at least min-dimension, but can be larger, depending
			; on the layout method of your parent.
			;
			; dimension is a special plug in that it is allocated arbitrarily by the marble as a !plug,
			; but its valve, will be mutated into what is required by the frame.
			;
			; the observer connections will remain intact, but its subordinates are controled
			; by the frame on collect.
			dimension: 200x300
			
			
			;-        min-dimension:
			;
			; minimal space required by this frame including any layout properties like margins,
			; borders, padding, frame banner, required size and accumulated minimum sizes of collection.
			;
			; used by dimension
			min-dimension: 30x30
			
			
			;-        content-dimension:
			; same as dimension with our own added size requirements removed (borders, margins, etc)
			content-dimension: none
			
			;-        content-min-dimension:
			; same as min-dimension without our own added size requirements removed (borders, margins, etc)
			content-min-dimension: none
			
			
			;-        content-spacing:
			; accumulates all the offsets in our collection
			content-spacing: none
			
			
			
			
			;-        origin:
			; this is the origin we supply to our children
			; a clip-region might also use this value or the position.
			;
			; normally, the origin is connected to border-size and offset
			origin: 5x5
			
			
			;-        clip-region
			; our own calculated global cliping rectangle, is affected by parent frame clip regions once collected.
			; until a marble is collected, its clipping region makes it invisible (from -1x-1 to -1x-1)
			clip-region: none
			
			
			;-        parent-clip-region:
			parent-clip-region: none
			
		]
		

		;-    collection:
		; stores any marbles we contain (link to?)
		; ATTENTION:  ONLY use the collect() & to manipulate this list.
		collection: none
		
		
		;-    frame-bg-glob:
		; a glob used to render any frame visuals behind marbles.
		; intersects our clip region with that of our frame.
		;
		; this allows glass to simulate view's hierarchical nested face clipping using draw !!!
		frame-bg-glob: none

		;-    frame-fg-glob:
		; a glob used to render any frame visuals Over its marbles.
		; the default frame uses this to restore its frame's clip region.
		frame-fg-glob: none


		;-    spacing-on-collect:
		; when collecting marbles, automatically set their offset to this value
		spacing-on-collect: 5x5
		
		
		
		;-    layout-method:
		; this changes the frame into various types of grouped layout methods.
		;
		; values are: [row, column, absolute, relative, column-grid, row-grid, explode]
		;
		; changing this value at run-time should only be performed by expert programmers
		; since it requires rebuilding outer panes to adjust to new inner values.
		;
		; if the method changes and is incompatible with the previous method, some layout 
		; breakage will result in outer panes, since the various calculated sizing parameters
		; will not be updated for them.
		;
		; usually, this means calling refresh on the most outer frame which can be affected by
		; the change to this frame.
		; 
		layout-method: 'column
		
		
		;-    valve []
		valve: make valve [

			type: '!marble


			;-        style-name:
			style-name: 'frame
		

			;-        is-frame?:
			is-frame?: true


			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			glob-class: none
			

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
						border-color  !color (random white)
						corner !integer
						; uncomment to debug
;						clip-region !block ([0x0 1000x1000])
;						min-dimension !pair
;						content-dimension !pair
;						content-min-dimension !pair
						active? !bool
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						; event backplane
						position dimension active?
						[
							(
								either data/active?= [
									compose/deep [
										line-width 1 
										pen none 
										fill-pen (to-color gel/glob/marble/sid) 
										box (data/position=) (data/position= + data/dimension= - 1x1)
									]
								][
									[]
								]
							)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						
						; FG LAYER
						position dimension color border-color corner
						;------
						; uncomment following for debugging
						;
						;   min-dimension content-dimension content-min-dimension
						;------
						[
							; here we restore our parent's clip region  :-)
							fill-pen (data/color=)
							pen (data/border-color=)
							line-width 1
							box (data/position=) (data/position= + data/dimension= - 1x1) (data/corner=)
							
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
			

			;-        fg-glob-class:
			; class used to allocate and link a glob drawn IN FRONT OF the marble collection
			;
			; windows use this to create an input blocker, for example.
			fg-glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup  these will be stored within the instance under input
						position !pair  ( random 200x200 )
						dimension !pair ( 300x300 )
						enabled? !bool
						;color !color
						;border-color  !color (random white)
						;clip-region !block ([0x0 1000x1000])
						;parent-clip-region !block ([0x0 1000x1000])
					]
					
					;-            glob/gel-spec:
					gel-spec: [
						;---
						; event backplane
						enabled? position dimension
						[
							(
								either not data/enabled?= [
								compose [
									pen none
									fill-pen (white) ; erases backplane.
									box  (data/position=) (data/position= + data/dimension= - 1x1)
								]
								][ [] ]
							)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						; position dimension color border-color clip-region parent-clip-region
						enabled? position dimension
						[
							; here we restore our parent's clip region  :-)
							;clip (data/parent-clip-region=)
							
							(
								either not data/enabled?= [
									compose [
										pen none
										fill-pen (theme-bg-color + 0.0.0.100)
										box  (data/position=) (data/position= + data/dimension= )
									]
								][
									[]
								]
							)
							
						]
						
						; controls layer
						;[]
						
						
						; overlay 
						;[]
					]
				]
			]

		
			;-----------------
			;-        gl-materialize()
			;
			; see !marble for details
			;-----------------
			gl-materialize: func [
				frame [object!]
			][
				vin [{frame/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-materialize()}]
				; manage relative positioning
				;if relative-marble? frame [
					frame/material/position: liquify*/fill epoxy-lib/!junction frame/material/position
					;link* frame/material/position frame/aspects/offset
				;]

				frame/material/origin: liquify*/fill !plug frame/material/origin
				frame/material/dimension: liquify*/fill !plug frame/material/dimension
				frame/material/content-dimension: liquify*/fill !plug frame/material/content-dimension
				frame/material/min-dimension: liquify*/fill !plug frame/material/min-dimension
				frame/material/content-min-dimension: liquify*/fill !plug frame/material/content-min-dimension
				
				
				; manage resizing
				frame/material/content-fill-weight: liquify*/fill !plug frame/material/content-fill-weight
				frame/material/fill-weight: liquify*/fill !pair-mult frame/material/fill-weight
				frame/material/fill-accumulation: liquify*/fill !plug frame/material/fill-accumulation
				frame/material/stretch: liquify*/fill !plug frame/material/stretch
				frame/material/content-spacing: liquify*/fill !plug 0x0
				frame/material/border-size: liquify*/fill !plug frame/material/border-size
				
				; this controls where our PARENT can draw we link to it, cause we restore it after our marbles 
				; have done their stuff.   We also need it to resolve our own clip-region
				; 
				; clip regions are stored as a block containing two pairs
				;marble/parent-clip-region: liquify* !plug
				
				
				; this controls where WE can draw
				frame/material/clip-region: liquify* epoxy-lib/!box-intersection
				;link* frame/material/clip-region frame/material/position
				;link* frame/material/clip-region frame/material/dimension
				
				frame/material/parent-clip-region: liquify* !plug 
				
				; our link itself after.
				;marble/material/origin: liquify*/link epoxy/!fast-add marble/material/position
				
				
				; this is meant for styles to setup their specific materials.
				;marble/valve/setup-materials marble
				
				vout
			]
			
			
			
			

			
			;-----------------
			;-        accumulate()
			;
			; add one or more marble(s) in our collection
			;
			; this is just a wrapper which accepts several input types.
			;
			; it is optimised for collecting several marbles at once.
			;
			; when actively controling marbles, use GL-COLLECT() directly.
			;
			;-----------------
			accumulate: func [
				frame [object!]
				marbles [object! block!]
				/local marble fg-glob
			][
				vin [{frame/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/accumulate()}]
				; normalize the input type,
				; if marbles is a block, it must only contain a series of marble OBJECTS.
				marbles: compose [(marbles)]
				
				vprint [length? marbles " Marble(s) to collect"]
				
				if object? frame/frame-fg-glob [
					vprint "must unlink FG GLOB"
					fg-glob: frame/frame-fg-glob
					frame/frame-fg-glob: none
					frame/glob/valve/unlink/only frame/glob fg-glob
				]
				
				; collect every marble
				foreach marble marbles [
					frame/valve/gl-collect frame marble
				]
				
				;ask ""
				
				if object? fg-glob [
					vprint "Relinking FG GLOB"
					frame/frame-fg-glob: fg-glob
					fg-glob: none
					frame/glob/valve/link frame/glob frame/frame-fg-glob
				]
				
				;----
				; cleanup GC
				marble: marbles: frame: fb-glob: none
				
				vout
			]
			
			;-----------------
			;-        link-glob()
			; callback used to perform the link of a collected marble.
			;
			; in some styles, collected marbles aren't directly linked to the frame's 
			; glob, but to an intermediate.
			;-----------------
			link-glob: func [
				frame
				marble
			][
				vin [{frame/link-glob()}]
				frame/glob/valve/link frame/glob marble/glob
				vprobe content frame/glob
				vout
			]
			
			
			;-----------------
			;-        unlink-glob()
			; callback used to perform the unlink of a discarded marble.
			;
			; in some styles, collected marbles aren't directly linked to the frame's 
			; glob, but to an intermediate.
			;-----------------
			unlink-glob: func [
				frame
				marble
			][
				vin [{frame/unlink-glob()}]
				frame/glob/valve/unlink/only frame/glob marble/glob
				;vprobe content frame/glob/reflection
				vout
			]
			
			

			
			;-----------------
			;-        gl-collect()
			;
			; add a marble to a frame.
			;
			; use accumulate() when collecting several marbles at a time
			;
			; it is THE ONLY LEGAL WAY to assign marbles to a frame.
			;
			; ATTENTION: collecting a marble which is already in a frame, automatically 
			; removes it from that frame.
			;
			; <TO DO> refinements: 
			;   /at index [integer! object!]  ; same as /before when used with object!
			;   /before marble [object!]
			;   /after marble [object!]
			;-----------------
			gl-collect: func [
				frame [object!]
				marble [object!]
				/top "collects at the top rather tahn the end"
				/local frm
			][
				vin [{frame/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-collect()}]
				;vprint ["collecting one marble of type: " to-string marble/valve/style-name ]
				
				either frm: get in frame 'collect-in-frame [
					marble/frame: frm
					frm/valve/gl-collect frm marble
				][
					; make sure we add marbles UNDER frame's fg-glob
					if object? frame/frame-fg-glob [
						;print "must unlink FG GLOB"
						frame/glob/valve/unlink/only frame/glob frame/frame-fg-glob
					]
					
					; make sure the marble isn't shared in several frames
					if any [
						; marble is framed, but its from another collection
						all [
							not same? marble/frame frame
							marble/frame
						]
						all [
							; on init, the frame is set, but its not yet collected, ignore the discard in this case.
							same? frame marble/frame
							find frame/collection marble
						]
					][
						; note:  gl-discard() calls discard() on its own
						marble/frame/valve/gl-discard marble/frame marble
					]
	
	
					
					; assign this frame to the marble
					marble/frame: frame
					
					; hoard it in our collection
					either top [
						insert frame/collection marble
					][
						append frame/collection marble
					]
					
					; tell our glob to add the marble's graphics to our graphics.
					link-glob frame marble
	
	
					; make sure fg-glob is ALWAYS in front of marbles
					if object? frame/frame-fg-glob [
						;print "Relinking FG GLOB"
						frame/glob/valve/link frame/glob frame/frame-fg-glob
					]
	
					
					; rarely, if ever, used... but may be usefull for specialized layout styles
					; this is advanced stuff, use with caution.	
					frame/valve/collect frame marble
				]
				vout
			]
			
			
			;-----------------
			;-        collect()
			;
			; this is a style-specific collection method for custom styles.
			;
			; it is evaluated WITHIN the low-level internal gl-collect() call, AFTER gl-collect has completed.
			;
			; this is not intended for casual users, there are many things to know when collecting a marble,
			; and full understanding of the framework is required.
			;
			; nonetheless, advanced users will enjoy the fact that they can actually change how marbles
			; are stacked visually, so there is virtually no limit beyond what Draw can accomplish.
			;-----------------
			collect: func [
				frame
				marble
			][
				;vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/collect()}]

				;vout
			]
			
			
			

			;-----------------
			;-        gl-discard()
			;
			; remove one or more marble(s) from OUR collection
			;
			; the only valid word marble value is 'all ('last , 'first are obvious enhancements)
			;
			; note that this doesn't destroy the marbles, it just removes it/them from our collection.
			;
			; ATTENTION: care must be taken to supply only marbles which actually are part of the frame's collection
			;            otherwise an error WILL BE RAISED!
			;-----------------
			gl-discard: func [
				frame [object!]
				marble [object! block! word!]
				/local marbles blk frm
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-discard()}]
				
				either frm: get in frame 'collect-in-frame [
					frm/valve/gl-discard frm marble
				][
					; normalize the input type
					switch type?/word marble [
						word! [
							if marble = 'all [
								vprint "Discarding ALL marbles"
								marbles: copy frame/collection
							]
						]
						object! [
							marbles: reduce [marble]
						]
						block! [
							marbles: marble
						]
					]
					
					
					vprint ["number of marbles: " length? marbles]
					
					foreach marble marbles [
						vprint "-"
						vprobe type? :marble
					]
					
					
					foreach marble marbles [
						vprint "--------------------"
						vprint ["type? marble: " type? marble]
						vprint ["marble:       " marble/sid]
						vprint ["marble/frame: " all [marble/frame marble/frame/sid]]
						
						either blk: find frame/collection marble [
						
							; first discard a style's collection customisation
							frame/valve/discard frame marble
							
							; remove marble from collection
							remove blk
	
							; disconnect the marble position from its frame
							if relative-marble? marble [
								if object? get in marble/material 'position [
									if 2 = length? marble/material/position/subordinates [
										marble/material/position/valve/unlink/tail marble/material/position
									]
								]
							]
							
							; disconnect the marble's glob from its frame
							unlink-glob frame marble
							
							; detach marble from frame
							marble/frame: none
							
							
						][
							to-error "Trying to discard marble from wrong frame"
						]
	
					]
				]
				vout
			]
			
			
			
			
			
			
			;-----------------
			;-        discard()
			;
			; a style should undo any special stuff it might do when it collect collected
			;-----------------
			discard: func [
				frame
				marble
			][
				vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/discard-hook()}]
				
				vout
			]
			
			
						
			
			
			;-----------------
			;-        gl-fasten()
			;
			; low-level default GLASS fastening.
			;
			; perform all linkeage required for this frame to effectively layout its collection.
			;
			; this is usually only called once, when our collection has changed.  since we must update
			; how each marble is related to its siblings and how we compare to the whole collection's new
			; content.
			;
			; the frame is responsable for allocation and linking marbles so the layout will
			; correspond to the frame's intended layout look and feel.
			;
			; Fasten is where MUTATIONS will take place on materials, so do not expect any specific
			; marble to retain its previous marble/valve after gl-fasten is called.
			;
			; the frame will always call fasten on its marble collection members BEFORE it performs its own
			; fastening on the marbles.
			;
			; note, fasten() on a marble is ONLY called from frames ... control-type
			; marbles never call gl-fasten() directly !!
			;
			;
			; Note, right now, gl-fasten isn't optimised for speed but raw robustness... so for this reason,
			; each fasten call, unlinks the whole collection and refastens it from scratch.  this way we are
			; sure that strange collect() calls do not corrupt the display by adding a new marble somewhere
			; in the middle of the collection.
			;
			; Once glass will mature and usage patterns become obvious, we will improve gl-fasten(). 
			;
			; at least, gl-fasten is called when the whole collection is accumulated, not everytime a single 
			; marble is collected
			;-----------------
			gl-fasten: func [
				frame
				/local marble previous-marble mtrl mmtrl
			][
				vin [{frame/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/gl-fasten()}]
				
				mtrl: frame/material
				
				;-            -wrapper
				if find frame/options 'wrapper [
					;vprint "SPECIFYING WRAPPER!"
					;vprint content* frame/aspects/offset
					link*/reset mtrl/position frame/aspects/offset
				]


				; setup our own materials				
				link*/reset mtrl/origin reduce [
					mtrl/position 
					mtrl/border-size
				]
				link*/reset mtrl/content-dimension reduce [
					mtrl/dimension
					mtrl/border-size
					mtrl/border-size
				]
				
				link*/reset mtrl/min-dimension reduce [
					mtrl/content-min-dimension
					mtrl/border-size
					mtrl/border-size
					frame/aspects/dimension-adjust
				]

				;-           -mutate
				; mutate our materials
				mtrl/origin/valve: epoxy-lib/!pair-add/valve
				mtrl/content-dimension/valve: epoxy-lib/!pair-subtract/valve
				mtrl/min-dimension/valve: epoxy-lib/!pair-add/valve
				
				switch frame/layout-method [
					column [
						;vprint "COLUMN!"
						; position
						mtrl/content-min-dimension/valve: epoxy-lib/!vertical-accumulate/valve
						mtrl/content-fill-weight/valve: epoxy-lib/!vertical-accumulate/valve
						mtrl/content-spacing/valve: epoxy-lib/!vertical-accumulate/valve
					]
					
					; 
					row [
						;vprint "ROW!"
						; position
						mtrl/content-min-dimension/valve: epoxy-lib/!horizontal-accumulate/valve
						mtrl/content-fill-weight/valve: epoxy-lib/!horizontal-accumulate/valve
						mtrl/content-spacing/valve: epoxy-lib/!horizontal-accumulate/valve
					]
				]


				
				; setup my clip-region
				
				; link to my parent's clip-region
				
				
				;-            -reset frame
				
				; reset our marble-dependent material properties
				unlink*/detach mtrl/content-fill-weight
				unlink*/detach mtrl/stretch
				unlink*/detach mtrl/content-spacing
				
				link*/reset mtrl/content-min-dimension mtrl/content-spacing

				
				previous-marble: none
				
				; manage collection
				;-               -collection
				foreach marble frame/collection [
					mmtrl: marble/material
					either previous-marble [
						; offset relative to previous marble
						link*/reset mmtrl/position previous-marble/material/position
						link* mmtrl/position previous-marble/material/dimension
						link* mmtrl/position marble/aspects/offset
						
						; accumulate fill weight
						link*/reset mmtrl/fill-accumulation  mmtrl/fill-weight
						link* mmtrl/fill-accumulation  previous-marble/material/fill-accumulation
						
						either frame/spacing-on-collect [
							;if -1x-1 = content* marble/aspects/offset  [
								fill* marble/aspects/offset frame/spacing-on-collect
							;]
						][
							;if -1x-1 =  content* marble/aspects/offset  [
								fill* marble/aspects/offset 0x0
							;]
						]
						
					][
						if frame/spacing-on-collect [
							;unless content* marble/aspects/offset  [
								;first item is at 0x0 by default
								fill* marble/aspects/offset 0x0
							;]
						]

						; offset relative to frame
						link*/reset mmtrl/position mtrl/origin
						link* mmtrl/position marble/aspects/offset
						
						; set fill weight
						link*/reset mmtrl/fill-accumulation  mmtrl/fill-weight
					]
					
					; accumulate all content.
					link* mtrl/content-min-dimension mmtrl/min-dimension
					link* mtrl/content-spacing marble/aspects/offset
					
					
					;-               -sizing
					;
					; traditional GLASS resizing algorithm implemented using dataflow!
					; connect dimension to requirements.
					link*/reset mmtrl/dimension reduce [
						mtrl/content-dimension
						mtrl/content-min-dimension
						mtrl/content-fill-weight
						mmtrl/min-dimension
						mmtrl/fill-weight
						mmtrl/fill-accumulation
						mtrl/content-spacing
					]
					
					; accumulate frame fill weight
					link* mtrl/content-fill-weight mmtrl/fill-weight
					
					link*/reset mtrl/fill-weight reduce [ mtrl/content-fill-weight frame/aspects/fill-scale  ]
					
					
					;-------
					; take care of collection MUTATIONS
					mmtrl/fill-accumulation/valve: epoxy-lib/!pair-add/valve
					
					switch frame/layout-method [
						column [
							;vprint "COLUMN!"
							; position
							mmtrl/position/valve: epoxy-lib/!vertical-shift/valve
							mmtrl/dimension/valve: epoxy-lib/!vertical-fill-dimension/valve
						]
						
						row [
							;vprint "ROW!"
							; position
							mmtrl/position/valve: epoxy-lib/!horizontal-shift/valve
							mmtrl/dimension/valve: epoxy-lib/!horizontal-fill-dimension/valve
						]
					]
					
					
					previous-marble: marble
				]
				
				
				;------
				; frame inner-fastening
				if find frame/options 'wrapper [
					;vprint "this is a wrapper"
					; wrappers are simple dimension containers
					mtrl/dimension/valve: !plug/valve
					
					; provide a usefull default wrapper dimension
					; if size is later filled manually this link is ignored as usual by liquid .
					link*/reset mtrl/dimension mtrl/min-dimension
				]
				
				; perform any style-related fastening.
				frame/valve/fasten frame
				vout
			]
			
			
						
			;-----------------
			;-        fasten()
			;
			; style-oriented public fasten call.  called at the end of (within) gl-fasten()
			;
			; CURRENTLY NOT ENABLED  !!!
			;-----------------
			fasten: func [
				frame
			][
				;vin [{glass/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/fasten()}]
				
				;vout
			]
			
			

			;-----------------
			;-        specify()
			;
			; parse a specification block during initial layout operation
			;
			; frames create new marble instances at specify time.
			; they are also responsible for calling layout setup operations providing any
			; environment which is required by new marbles
			;-----------------
			specify: func [
				frame [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				/local marble item pane data marbles set-word pair-count tuple-count
			][
				vin [{frame/!} uppercase to-string frame/valve/style-name {[} frame/sid {]/specify()}]
				;v?? spec
				
				stylesheet: any [stylesheet master-stylesheet]
				pair-count: 1
				tuple-count: 1
				
				parse spec [
					any [
						copy data ['with block!] (
							do bind/copy data/2 frame 
						)
						
						| 'stiff-x (
							fill* frame/aspects/fill-scale 0x1
						)
						
						| 'blocking (
							fill* frame/aspects/enabled? false
						)
						
						| 'stiff-y (
							fill* frame/aspects/fill-scale 1x0
						)
						
						| 'stiff (
							fill* frame/aspects/fill-scale 0x0
						)
						
						| 'adjust  set data pair!  ( 
							fill* frame/aspects/dimension-adjust data
						)
						
						| 'corner set data integer! (
							fill* frame/aspects/corner data
						) 
						
						| 'activate (
							;print "FRAME ACTIVE"
							fill* frame/aspects/active? true
						)
						
						| 'tight (
							frame/spacing-on-collect: 0x0
							if block? frame/collection [
								foreach marble frame/collection [
									fill* marble/aspects/offset 0x0
								]
							]
							fill* frame/material/border-size 0x0
						) 
						
						| set data tuple! (
							switch tuple-count [
								1 [
									;vprint "frame COLOR!" 
									;vprint data
									fill* frame/aspects/border-color data
								]
								
								2 [
									fill* frame/aspects/color data
								]
							]
							tuple-count: tuple-count + 1
						) 
						| set data pair! (
							switch pair-count [
								1 [  
									;vprint "frame Border-size!" 
									fill* frame/material/border-size data
								]
								
								2 [
									frame/spacing-on-collect: data
								]
							]
							pair-count: pair-count + 1
						
						)
						| set data block! (
							;vprint "frame MARBLES!" 
							pane: regroup-specification data
							new-line/all pane true
							;vprint "skipping inner pane attributes"
							pane: find pane block!
							
							if pane [
								; create & specify inner marbles
								foreach item pane [
									if set-word? set-word: pick item 1 [
										; store the word to set, then skip it.
										; after we use set on the returned marble.
										item: next item
									]
									either marble: alloc-marble/using first item next item stylesheet [
										marbles: any [marbles copy []]
										
										; set the frame, just so child gl-fasten, may use the frame to take
										; contextual decisions.
										append marbles marble
										marble/frame: frame
										marble/valve/gl-fasten marble
										
										if set-word? :set-word [
											set :set-word marble
										]
										
									][
										; because of specification's parsing, this code should never really be reached
										vprint ["ERROR creating new marble of type: " item " in frame!"]
									]
								]
								
								; add all children to our collection
								frame/valve/accumulate frame marbles
							]
							; take this frame and fasten it. (might be empty)
							; we remove this since it caused a double fastening of all frames!
							; it was instead added to the layout function directly.
						)
						| skip 
					]
				]
				
				frame/valve/dialect frame spec stylesheet
				
				;------
				; cleanup GC
				marbles: spec: stylesheet: marble: pane: item: data: none
				vout
				frame
			]
		]
	]
]
