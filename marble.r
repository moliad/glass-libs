REBOL [
	; -- Core Header attributes --
	title: "Glass marble "
	file: %marble.r
	version: 1.0.2
	date: 2014-6-4
	author: "Maxim Olivier-Adlhoch"
	purpose: {The core object which defines the basic GLASS functionality. All styles and components are derived from marble.}
	web: http://www.revault.org/modules/marble.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'marble
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/marble.r

	; -- Licensing details  --
	copyright: "Copyright © 2014 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2014 Maxim Olivier-Adlhoch

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
			-Added border-color attribute
			-added stiff-x & stiff-y  to dialect 
		v1.0.2 - 2014-06-04
			FEAT: 
			-Auto-sizing now part of basic marble dialect.    
			-polymorphic dialecting through the use of  'local-dialect  value in the marble. 
			-connect-to facet, allows to quickly link two marbles using their default facet directly.  so a label can connect-to a scroller directly, for example.
			FIX:
			-mutation of min-size aspect for real time auto-sizing enabling (no need to build a style in glaze anymore, just use auto-size facet)
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Marbles are the core building block of a GLASS GUI.  They are almost entirely driven
		by dataflow, and their event handling is both powerfull, simple and very extensible.
		
		Used as-is, the basic marbles act like labels and are used directly as such in glaze.
		
		One very special aspect of glass is the fact that there is no "layout engine".  There is
		no single method of arranging elements in the interface.  Although on the surface it 
		looks as though this is occuring, in detail it is not managed by an overall system.
		
		The layout is built by performing a process called fastening.  It's like tying some rope
		around objects so they hold each other.  Instead of describing the layout in an algorythm
		we let each item know how it should place itself on the layout.  in a sense, each item
		becomes self aware of its role in the layout, rather than having a master telling it where
		to go.  Because of this, any marble's layout maybe overidden and be tuned to a specific
		problem, even within a group or frame.  Usually you'd need to make your own layout system
		and integrate an exception and it all gets VERY complicated, real fast.
		
		Note that the !marble object is in constant evolution and should not be relied on to be exactly
		the same from release to release.
		
		the main public API is described below, briefly.  Items listed here should stay pretty
		much intact in future releases.  Their exact functionality may change, but the intent
		and overall idea won't.
		
		The marble structure will change a little bit in future versions when the theme engine
		will be implemented.  Notably, aspects which define colors will now be setup within the 
		shader node instead.
			
		
		
		aspects:		
			One of the highlights of marbles is that they define their API not by accessors and callbacks,
			as much as by defining plugs to which you can connect things.
			
			The public properties of marbles are always set within the aspects: object.
			
			Whenever data coming into a marble changes, the marble itself will adapt automatically.
		
			If you pipe your data, then changes within the marble may also affect the external data 
			automatically.
			
			Also be mindfull that some aspects will be the clients of a bridge within the material.
			Because of this, you generally shouldn't change the plug class of an aspect, but may
			pipe to it at will.  Each marble will have its own documentation on how to
			understand the aspects.  Some may have limitations as to how they can be linked.
			
			Also note that aspects are different for each marble.
			
		Material:
			These are similar to aspects but are managed internally by the marble.  Some of these
			are required by the default frame fastening procedure.   Usually your custom marbles 
			will define a few additional materials which help in intermediate data handling.
			
			Note that materials may be linked TO, but you should never relink the materials themselves
			unless you are doing some tricky stuff and know what you are doing.
		
		
		Shader:
			!shader nodes will be derived from the !fluid aspect-oriented programming framework.
		
			Shaders will define both the visual properties of a marble and the rendering procedure which uses
			marble aspects, materials and shader properties.
		
			More on this when its released.
			
			
		Stream:
			Any marble may implement event handling by attaching handlers to the marble's stream.
			
			Streams allow you to totally control all aspects of input/outputs related to your marble.
			
			This includes handling and generating of entirely new events, even sending events to other marbles.
			
			Some hardware events, will be transformed upstream (by the window or application) and 
			may never reach your marble.  Other events may, in fact, generate several new events.
			
			Also, you may generate new events in your handlers, which will end up at your
			own marble.  This allows the whole system to evolve without it being tied to the GLASS
			framework itself and a strict set of capabilities.
			
			This is why things like refresh and focus are handled directly at the stream level and
			not as a special function deep within some library.
			
			The handlers will only modify aspects and materials. this means that they are also independent
			of the marble.  handlers do not directly manipulate visuals.  They should only change 
			public states which are interpreted by the rendering.
			
			usually, handlers will be custom tailored to specific marbles, but you may very well use
			any handler in your custom styles and refine them for more specific event requirements.
			
			for more information on the stream, look at the event library documentation.
			
			
		user-id/user-data:
			These are usefull for an application to store instance-related information which will never
			be modified or created by GLASS.
			
			The user-id allows you to refer to a marble by name in your code traces or even to build
			interface searching functions (searching all marbles labeled as 'new, for example)
			
			The user-id is formally limited to a few datatypes, so look at its own description below to
			find out which ones are currently accepted.
			
			the user-data is usefull to store data which a callback might need to make itself local
			to this instance.  its just payload, can be anything (even a func) and will never be 
			mangled with by GLASS.
			
			
		actions:
			This is a handy mechanism which allows you to add a callback to ANY event which your marble
			recognizes.  The stream handlers are responsible for deciding which events can be triggered 
			via a callback, so check their individual documentation.
			
			Very few situations require the use of event callbacks, but when they are needed, just add
			a function with the name of the event as the function name and it will be called with
			the event object, just after the handler(s) are done with the event.
	}
	;-  \ documentation
]





;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'marble
;
;--------------------------------------

slim/register [
	
	;- LIBS
	
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		plug?
		liquify*: liquify
		content*: content 
		notify*: content 
		fill*: fill
		link*: link
		unlink*: unlink
		dirty*: dirty
		bridge*: bridge
		attach*: attach
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
		do-event
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	
	event-lib: slim/open 'event none
	slim/open/expose 'utils-series none [ include ]

	

	;--------------------------------------------------------
	;-   
	;- !MARBLE[ ]
	!marble: make !plug [
	
	
		;--------------------------
		;-    default-data-aspect:
		;
		; within the aspects (the aspects context which follows) which one is
		; considered the default data driver to attach or link to?
		;
		; note that data driver means the value being OUTPUT by the marble, not the data it is being fed.
		;
		; we use 'label by default, cause its usually in all marbles, but you should change this
		; when its appropriate, like a state for toggles or a "selected" list for dropdowns.
		;
		; internally, some code (like the linkage dialecting) will use this default plug which can change
		; from marble to marble.
		;
		; you MUST use the marble's 'GET-DEFAULT-ASPECT  valve method to retrieve the marble's default aspect.
		; some marble classes might change how this is determined.
		;--------------------------
		default-data-aspect: 'label
		
		
	
		;-    Aspects[ ]
		;
		; (public marble plugs)
		;
		; stores any controlable/dynamic aspect of a marble.
		;
		; each aspect becomes a liquid !plug
		;
		; you may link or pipe any of these at will within/to your application.
		;
		; they are automatically created at init, much like the globs within.
		; some glob inputs will link TO these, so be sure not to reallocate the plugs themselves.
		;
		; never store the aspects object directly, it can be replaced by the marble at any time.
		;
		; aspects include dynamic theme data like resizing and layout information... so don't poke here
		; unless you really know what you are doing.
		;
		; some of the aspects will be filled up by the layout algorythm, some might be setup by gl-specify() directly.
		aspects: context [
			;-       offset
			offset: 10x10   ; this is the relative to parent coordinates your marble is at.

			;-       size:
			; this is the user controlable size of the marble, 
			; if size is none, minimum-dimension ignores it.
			; 
			; and automatically calculates a size instead, based on font and label.
			;
			; note that if size has a -1 component then only that orientation is automatically
			; calculated. (this allows you to scale one orientation based on the other's manually-set size)
			size: -1x-1

			;-       state:
			state: none

			;-       color:
			; bg color
			color: none
			
			;-       label-color:
			label-color: black
			
			;-        border-color:
			; marbles don't have a border by default
			border-color: none
			
			;-       label:
			label: none
			
			;-       font:
			font: theme-base-font
			
			;-       align:
			align: 'center
			
			;-       hover?:
			hover?: none
			
			;-       padding:
			padding: 3x2
			
			;-       corner:
			corner: 0
		]
		
		
		;-    Material[]
		;
		; (private marble plugs)
		;
		; stores processed aspects, which are usually linked directly by the glob and between each other.
		;
		; many material properties link to the public aspects as the basic data to manipulate for the 
		; marble's consumption. 
		;
		; materials are managed by the various levels of glass.  This is the general purpose container for 
		; any dynamic liquid linkage.
		;
		; this is where we do a lot of the layout calculation through frame's fasten() call.
		;
		; each marble has its own material instance.  Never store the material object itself directly elsewhere, 
		; it may be replaced by the marble at any time.  
		;
		; ALWAYS refer via marble/material
		;
		material: context [
			;-       position:
			; the global coordinates your marble is at 
			; (automatically linked to gui by parent frame).
			;
			; note that if your marble is within a pane, the position is relative
			; to ITS position MINUS any transformation it adds
			position: 0x0 
			
			
			;-       window-offset:
			; this is experimental, and used only rarely (usually within event
			; handlers.  it SHOULD NOT be used within GLOBs, cause we do not 
			; want double position calculation.
			;
			; each window-offset is linked to its frame in a way which allows
			; any marble to know its absolute window position.
			;
			; panes, resets the positioning because they use 0x0 as the origin
			; and use a translate to push the graphics within a face instead of 
			; recalculating the complete collection resizing.
			window-offset: none
			
			
			;-       fill-weight:
			; fill up / compress extra space in either direction (independent), but don't initiate resising
			;
			; frames inherit & accumulate these values, marbles supply them.
			;
			; some frames & groups might have overrides which actually allow you to make stiff frames.
			fill-weight: 1x0
			
			;-       fill-accumulation:
			; stores the accumulated fill-weight of this and previous sibling marbles.
			;
			; allows you to identify the fill regions
			;
			;	accumulation  0  2 3   6   6  8
			;	fill           2  1  3   0  2
			;	gui           |--|-|---|   |--|
			;
			; using regions fills all gaps and any decimal rounding errors are alleviated.
			fill-accumulation: 0x0
			
			
			;-       stretch:
			; marble benefits from extra space, initiates resizing ... preempts fill
			;
			;
			; frames inherit & accumulate these values, marbles supply them.
			stretch: 0x0
			
			
			
			;-       content-size:
			; depending on marble type, the content-size will mutate into different sizing plugs
			; the most prevalent is the !text-sizing type which expects a !theme plug
			content-size: 0x0
			
			
			
			;-       min-dimension:
			; this is your internal calculated minimal dimension
			; it should include things like content, aspect's size, margins, padding, borders, etc.
			;
			; marbles usuall should allocate enough space to display data correctly,
			; frames will usually collect the minimum space required by its marble collection.
			;
			; frame uses this, but its each marble's responsability to set it up.
			min-dimension: 100x21
			
			
			
			;-       dimension:
			; computed size, setup by parent frame, includes at least, min-dimension, but can be larger, depending
			; on the layout method of your parent.
			;
			; dimension is a special plug in that it is allocated arbitrarily by the marble as a !plug,
			; but its valve, will be mutated into what is required by the frame.
			;
			; because of this, the dimension's instance may NOT contain/rely on any special attributes in
			; its plug instance.
			;
			; the observer connections will remain intact, but its subordinates are controled
			; by the frame on collect.
			;
			; this is what should actually get used by the glob.
			dimension: 0x0
			
		]
		
		
		
		;-    Shader:
		;
		; the shader will be the point of reference which stores theme (look & style) information.
		;
		; this plug is special, in that its the result of linking up various !shader nodes.
		; 
		; within a marble, where !shaders are used, any change to the shader will be refreshed dynamically
		; by any and all marbles which share this information.
		;
		; theme data includes default parameters for just about any aspect of a gui you wish to normalize,
		; like bg color, fonts, etc.
		;
		; because things are linked, within the theme manager, you can share and refine the theme specifically
		; for any level of the gui's marble, so two different marbles, although using the same class, might be
		; linked to two different branches of the same theme... one with larger fonts, used by banners,
		; the other using the default text font.
		;
		; this removes the need to create special styles simply to differentiate looks.
		;
		;shader: none
			
		
		;-    glob:
		; stores the glob instance used to render this marble
		; this can be a gel or stack type glob.
		glob: none
		
		
		
		
		;-    frame:
		; to what frame is this marble attached, once allocated?
		;
		; collect-marble() refreshes this correctly (its used by the frame on marble creation).
		frame: none
		
		
		;-    options:
		; store options for this marble.  This is internal to a marble and should never be
		; played with manually.
		;
		; usually an option will be added as a result of processing the marble's dialect so
		; that some detail is re-evaluated properly later-on.
		; 
		; currently supports:
		;
		;    wrapper:  the marble is a wrapper, so frame layout doesn't expect a parent frame.
		options: none
		
		;-    user-data:
		; this is a handy way to link application specific data within the marble,
		; so that you can refer to the application from within the marble.
		;
		; dome dialects might help you fill this value directly from the spec.
		;
		; to access this data in callbacks and actions, you'll usually do:
		;   event/marble/user-data
		;
		user-data: none
		
		
		;-    user-id:
		; you may put any of [string! integer! issue! word! tuple!] here, which will be used to refer to your
		; marble by name.
		;
		; the name need not be unique in a layout.  this is usefull to extract sets
		; of controls.
		;
		; some glass functions use this to browse a layout hierarchy 
		; and perform various operations on matching marbles.
		user-id: none
		
		
		
		;-    stream:
		; block of functions which are called on events.
		;
		; a stream is only allocated if you call add-handler on a marble.
		;
		; the marble dialect may do this for you.
		;
		; note: the api for streams is contained in the event.r module
		stream: none
		
		
		
		;-    actions[]
		actions: context [
;			;-----------------
;			;-        select()
;			;-----------------
;			select: func [
;				event
;			][
;				vin [{button/select()}]
;				vprint join content* event/marble/aspects/label " pressed" 
;				
;				vprobe event/marble/actions
;				
;				vout
;			]
;			
;			;-----------------
;			;-        release()
;			;-----------------
;			release: func [
;				event
;			][
;				vin [{button/release()}]
;				vprint join content* event/marble/aspects/label " clicked" 
;				vout
;			]
		]

		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'marble  
			
			
			;-        is-frame?:
			; separates between the two main marble types:
			;   controls:
			;     controls are the things you interact with within a gui.
			;
			;  frames:
			;     frames are used to create and manage the layout in general.
			;     most of what is true for a control is also true for a frame.
			is-frame?: false
			

			;-        is-viewport?:
			is-viewport?: false
			
			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair
						dimension !pair 
						label !string
						color !color 
						label-color !color
						border-color !color
						min-dimension !pair
						font !any
						align !word
						corner !integer
						padding !pair
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
						position dimension color label label-color border-color min-dimension font align corner padding
						[
							line-width 1
							(
								either any [
									tuple? data/color=
									tuple? data/border-color=
								] [
									compose [
										pen  (data/border-color=) 
										fill-pen (data/color=)
										box (data/position=) (data/position= + data/dimension= - 1x1) ( data/corner=)
									]
								][ [] ]
							)
							;pen (content* gel/glob/marble/frame/aspects/color)
							;line (data/position=) (data/position= + data/dimension=)
							;(prim-x data/position= data/dimension=  data/color= + 0.0.0.128 1)
							line-width 0
							pen (none)
							(
								prim-label/pad data/label= data/position= + 1x0 data/dimension= data/label-color= data/font= data/align= data/padding=
							)
							
							;---
							; the following fixes problem with AGG texts with spaces breaking up the pen color of any graphic which follows
							box 100000x100000 1000001x1000001
							
;							line-width 1
;							pen (red) 
;							fill-pen (0.0.0.200 + data/color=)
;							box (data/position=) (data/position= + data/min-dimension=)
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
			;-        set-aspect()
			;
			; interface to safely access aspect object.  does not generate errors on inexisting aspect names
			;
			; does not access materials since these are considered private to the marble & glass.
			;-----------------
			set-aspect: func [
				marble [object!]
				aspect [word!]
				value 
				/local success?
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/set-aspect()}]
				success?: either in marble/aspects aspect [
					fill* marble/aspects/:aspect value
					vprobe aspect
					vprobe value
					true
				][
					vprint ["aspect '" to-string aspect " not in marble"]
					vprint "assigment ignored"
					false
				]
				vout
				marble: aspect: value: false
				success?
			]


		
			;-----------------
			;-        aspect-list()
			; abstraction, in case this changes.  also prettier in code.
			;-----------------
			aspect-list: func [
				marble
			][
				;vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/aspect-list()}]
				;vout
				next first marble/aspects
			]
			
			
			;-----------------
			;-        material-list()
			; abstraction, in case this changes.  also prettier in code.
			;-----------------
			material-list: func [
				marble
			][
				;vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/material-list()}]
				;vout
				next first marble/material
			]
			
			
			;-----------------
			;-        link-glob-input()
			;-----------------
			; if any aspect or material names match glob input names, we link the glob to the aspect.
			;
			; just a very quick and handy way to define a style without needing to code it.
			;
			; ATTENTION: if a material property has the same name as an aspect, IT will be linked to the glob 
			;            (materials have precedence).
			;
			; if your glob needs manual control over how it uses an aspect, just name it
			; differently in the gel and create your own custom linkage in setup-marble().
			;
			; because end users do not have access to the inner glob, this name differentiation isn't 
			; a big deal.  the default naming in custom linkage is to use the aspect prefixed with '*
			; such that the 'position aspect would become '*position in the gel.
			;-----------------
			link-glob-input: func [
				marble
				/using glob
				/local item plug input inputs
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/link-glob-input()}]
				
				; use default glob or supplied one
				glob: any [glob marble/glob]
				
				inputs: extract glob/input 2
				
				;v?? inputs
				
				; map each input to a matching aspect or material
				foreach item inputs [
					;vprint item
					case [
						plug: get in marble/material item [
							if all [
								object? plug
								in plug 'valve ; is this really a plug?
							][
								input: select glob/input item 
								;vprint ["linking input:" to-string item]
								input/valve/link/reset input plug
							]
						]
						plug: get in marble/aspects item [
							;------------
							; this is faster at run-time, but causes some interference because the inputs
							; are type-converting
							;
;								input: select glob/input item 
;								fill* input content*  plug
;								marble/aspects/:item: input

							input: select glob/input item 
							;vprint ["linking input:" to-string item]
							input/valve/link/reset input plug
							
						]
					]
				]
				vout
			]
			
			
			
			
			;--------------------------
			;-          get-default-aspect()
			;--------------------------
			; purpose:  all marbles have one aspect which is considered the default one, usually used for their main data value.
			;
			; inputs:   
			;
			; returns:  a plug  (it should always fallback to label if it can't find anything more specific)
			;           it may return none, but in this case you are not setting up the marble properly.
			;
			; notes:    
			;
			; tests:    
			;--------------------------
			get-default-aspect: funcl [
				marble [object!]
			][
				vin "get-default-aspect()"
				; default aspect is the 
				def-aspect: any [
					attempt [ get in marble/aspects marble/default-data-aspect]
					attempt [ marble/aspects/label]
				]
				
				vout
				def-aspect
			]
			


			;-----------------
			;-        setup()
			;
			; low-level core marble setup.
			;
			; this setup expects you to be using the GLASS framework as-is, MODIFY AT OWN RISK.
			;
			; the reason liquid is used extensively in GLASS, is that it allows a lot of freedom in the setup
			; of a system without changing its interface.  If you use the aspects and gl-specify() function directly
			; glass might be completely replaced with new code and your application will still remain compatible.
			;
			; for example, a theme engine will be grafted to glass at some point, with no effect on your use
			; of the library, if you use the api exclusively.
			;
			; do not expect anything here to remain from version to version.
			;
			; the only valid interface to glass is via the style hooks, aspect plugs and public GLASS api module.
			;
			; this function mainly setups the internal glob requirements for marble and frames.
			; it also auto allocates aspects as plugs
			;
			; use setup-style() in styles which rely on default GLASS architecture, but require their own
			; specific intialisation.
			;-----------------
			setup: func [
				marble
				/local simple-aspects item
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/setup()}]
				; make an instance-specific property containers
				marble/aspects: make marble/aspects []
				marble/material: make marble/material []
				
				marble/options: copy []
				
				
				; usually empty, but may be required in some cases.
				marble/valve/setup-aspects marble
				
				
				
				;----
				; allocate aspects automatically
				foreach item aspect-list marble [
					;vprint [ "adding aspect: " item "> " marble/aspects/:item]
					unless plug? get in marble/aspects item [
						marble/aspects/:item: liquify*/fill !plug (either series? item: get in marble/aspects item [copy item][item])
					]
				]

				;----
				; allocate materials, 
				;
				; you are actully free to use your own materials and link them however you like.
				; the framework is simply there to help you get started with a decent layout
				; without much work required for you to customize or enhance it.
				;
				; if you use custom material names, the default frame marble won't be able to link
				; your marbles so you'll have to adapt its fasten() method
				
				marble/valve/gl-materialize marble
				marble/valve/materialize marble


				; allocate our glob(s)
				either marble/valve/is-frame? [
				
					; this is only used as a stack.
					marble/glob: liquify* !glob
					marble/collection: copy []
					
					; if the frame has any visuals, create and link them.
					if marble/valve/bg-glob-class [
						marble/frame-bg-glob: liquify*/with marble/valve/bg-glob-class compose [marble: (marble)]
						marble/valve/link-glob-input/using marble marble/frame-bg-glob
						marble/glob/valve/link marble/glob marble/frame-bg-glob
					]
								
					if marble/valve/fg-glob-class [
						
						marble/frame-fg-glob: liquify*/with marble/valve/fg-glob-class compose [marble: (marble)]
						marble/valve/link-glob-input/using marble marble/frame-fg-glob
						
						; the fg glob will be unlinked and relinked everytime new marbles are collected
						marble/glob/valve/link marble/glob marble/frame-fg-glob
					]
				][
					marble/glob: liquify*/with any [marble/valve/glob-class !glob] compose [marble: (marble)]
					marble/valve/link-glob-input marble
				]
				
				

				; style-related setup
				marble/valve/setup-style marble

				vout
			]
			


			
			;-----------------
			;-        test-handler()
			;
			; this handler is used for testing purposes only. 
			;-----------------
			test-handler: func [
				event [object!]
			][
				vin [{HANDLE MARBLE}]
				
				;print event/action
				switch event/action [
					start-hover [
						;fill* event/marble/aspects/hover? true
					]
					
					end-hover [
						;fill* event/marble/aspects/hover? false
					]
				]
				do-event event
				
				vout
				none
			]
			
			
			

			;-----------------
			;-        setup-style()
			;-----------------
			; a callback to extend anything in the marble AFTER Glass has finished with its own setup
			;
			; this is used by styles for their own custom data requirements.
			;
			; styles may also provide application setup hooks, but usually do so via extensions to the
			; the specification parser, using dialect()
			; 
			; most styles will also add default stream handlers (like viewports)
			;-----------------
			setup-style: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/stylize()}]
				
				; just a quick stream handler for all marbles
				event-lib/handle-stream/within 'test-handler :test-handler marble
				vout
			]
			
		
			;--------------------------
			;-        setup-aspects()
			;
			; when required, simply make this a function which
			; accepts a marble as only parameter. 
			;
			; it is called before any automatic treatment of aspects is done,
			; allows you setup special plug/pipe types for your aspects.
			;
			; its like the materialize function, but for aspects. it should be used sparingly.
			;
			; this is rarely required, but you may need it.
			;
			; when the automatic aspect setup detects a plug in one of the aspects,
			; it will let it be.
			; 
			;--------------------------
			setup-aspects: none
			
			
			
			
			
			;-----------------
			;-        gl-materialize()
			;
			; low-level default GLASS material allocation & setup.
			;
			; the purpose is mainly to allow OTHER nodes (like glob inputs) to link TO the materials themselves.
			;
			; at this stage, you should not LINK the MATERIALS to other plugs, because a lot of things are
			; still unknown... like the marble's frame, children, etc.  in fact, The
			; internal globs don't even exist yet.
			;
			; you may replace this function to overide how default glass materials are built by your class.
			; but you will also have to provide your own fasten and make sure your marbles
			; cooperate properly with the frame they are collected in.
			;
			; Note that glass actively uses a feature of liquid which is called mutation. 
			; MUTATION CHANGES THE CLASS (VALVE) of a liquid plug without changing the instance
			; itself.  
			;
			; The default Glass framework only mutates materials, NEVER aspects.  furthermore, it ONLY mutates 
			; plugs it allocates itself, usually within gl-materialize.
			;
			; If you simply wish to EXTEND the default glass marbles, use the stylize() & materialize() functions.
			; For examples, look at the styles in the default stylesheet.
			;
			; eventually, a theme/skin engine will hookup within the materialization process somehow.
			;-----------------
			gl-materialize: func [
				marble [object!]
				/local mtrl
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/gl-materialize()}]
				; manage relative positioning
				;if relative-marble? marble [
					; ! junction is a default, but it may change via frame-managed mutation.
				
				mtrl: marble/material
				
				; these are managed by the frame (will be mutated by it!)
				mtrl/position: liquify*/fill epoxy-lib/!junction mtrl/position
				mtrl/dimension: liquify*/fill epoxy-lib/!junction mtrl/dimension

				; these are managed by ourself, but will be used by our frame
				
				; the automatic label resizing is optional in marbles.
				either 'automatic = get in marble 'label-auto-resize-aspect [
					;probe "AUTO-SIZING!!!"
					mtrl/min-dimension: liquify* epoxy-lib/!label-min-size
				][
					mtrl/min-dimension: liquify*/fill !plug mtrl/min-dimension
				]
				mtrl/fill-weight: liquify*/fill !plug mtrl/fill-weight
				mtrl/fill-accumulation: liquify*/fill !plug mtrl/fill-accumulation
				mtrl/stretch: liquify*/fill !plug mtrl/stretch

				;]
				
				vout
			]
			
			
			
			;-----------------
			;-        materialize()
			; style-oriented public materialization.
			;
			; called just after gl-materialize()
			;
			; note materialization occurs BEFORE the globs are linked, so allocate any
			; material nodes it expects to link to here, not in setup-style().
			;
			; read the gl-materialize() function notes above for more details, which also apply here.
			;-----------------
			materialize: func [
				marble
			][
				;vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/materialize()}]
				;vout
			]
			
			
			



			;-----------------
			;-        gl-fasten()
			;
			; low-level default GLASS fastening.
			;
			; perform all linkeage required for this marble to effectively layout.
			;
			; usually, control-type marbles do not connect to their frames at this step, since 
			; the frame is responsable for allocation and linking marbles between themselves...
			;
			; use this when a style requires a special trick which is simple to perform 
			; here and won't break the frame's expectations.
			;
			; be extra carefull not to create link cycles, which will be detected and
			; generate an error by liquid (by default).
			;
			; the frame will always call fasten on the marble BEFORE it performs its own
			; fastening on the marble, so any link you do here will be at the head of the
			; subordinate block
			;
			; note, fasten() on a marble is ONLY called from frames ... control-type
			; marbles should never call gl-fasten() directly !!
			;
			;-----------------
			gl-fasten: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/gl-fasten()}]
				
				; the automatic label resizing is optional in marbles.
				;
				; current acceptible values are ['automatic | 'disabled]
				
				either 'automatic = get in marble 'label-auto-resize-aspect [
					; mutate based on existance of 'label-auto-resize-aspect in marble.
					marble/material/min-dimension/valve: epoxy-lib/!label-min-size/valve
					
					link*/reset/exclusive marble/material/min-dimension marble/aspects/size
					link* marble/material/min-dimension marble/aspects/label
					link* marble/material/min-dimension marble/aspects/font
					link* marble/material/min-dimension marble/aspects/padding
				][
					; mutate based on existance of 'label-auto-resize-aspect in marble.
					marble/material/min-dimension/valve: !plug/valve
					
					if in marble/aspects 'size [
						link*/reset  marble/material/dimension marble/aspects/size
					]
					;link/reset  marble/material/min-dimension marble/aspects/size
				]
				
				
				;probe content marble/material/min-dimension
				
				; perform any style-related fastening.
				marble/valve/fasten marble
				vout
			]
			
			
						
			;-----------------
			;-        fasten()
			;
			; style-oriented public fasten call.  called at the end of gl-fasten()
			;
			;-----------------
			fasten: func [
				marble
			][
				;vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/fasten()}]
				;vout
			]
			


			

			;-----------------
			;-        gl-specify()
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
			; marble type and add items to marble, on the fly!!
			;-----------------
			gl-specify: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				/wrapper
				;/local mbl
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/gl-specify()}]
				
				if wrapper [
					include marble/options 'wrapper
				]

				
				if function? get in marble/valve 'pre-specify [
					marble/valve/pre-specify marble stylesheet
				]
				
				marble: any [
					marble/valve/specify marble spec stylesheet
					marble
				]
				
				if function? get in marble/valve 'post-specify [
					marble/valve/post-specify marble stylesheet
				]
				
				vout
				
				marble
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
			; marble type or instance on the fly!!
			;
			; we now call the dialect() function which allows one to reuse the internal specify
			; dialect directly.
			;
			; dialect will simply be called after specify is done.
			;-----------------
			specify: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				;/local data pair-count tuple-count tmp
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/specify()}]
				other-marble: none
				pair-count: 0
				tuple-count: 0
				blk-count: 0
				local-dialect: [end skip]
				if in marble/valve 'dialect-rules [
					local-dialect: bind/copy (get in marble/valve 'dialect-rules) 'blk-count
				]
				parse spec [
				
				
					any [
						local-dialect
						
						| copy data ['with block!] (
							;print "SPECIFIED A WITH BLOCK"
							;marble: make marble data/2
							;liquid-lib/reindex-plug marble
							do bind/copy data/2 marble 
							
						) 
						
						| 'stiff (
							fill* marble/material/fill-weight 0x0
						) 
						
						| 'stiff-x (
							fill* marble/material/fill-weight 0x1
						) 
						
						| 'stiff-y (
							fill* marble/material/fill-weight 1x0
						) 
						
						| 'stretch set data pair! (
							fill* marble/material/fill-weight data
						) 
						
						| 'left (
							fill* marble/aspects/align 'WEST
						) 
						
						| 'right (
							fill* marble/aspects/align 'EAST
						) 
						
						| 'padding set data [pair! | integer!] (
							fill* marble/aspects/padding 1x1 * data
						) 

						| 'auto-size (
							marble: make marble [label-auto-resize-aspect: 'automatic]
							;marble/
						)
						
						
						
						;-----
						; attach a plug to ourself (keeping our value, if any).
						;
						; the net result is that he and we will be using OUR pipe server
						;-----
						| 'attach set client [object! | word!] (
							if word? client [client: get client]
							if liquid-lib/plug? client [
								aspect: marble/valve/get-default-aspect marble
								
								;----
								; get the aspect's current data, so we can put it back
								value-backup: content aspect
								
								attach* client aspect
								
								; sometimes, attaching clears the data, 
								; filling it up ensures it stays there and also generates a dirty propagation!
								fill aspect value-backup
							]
						) 
						
						;-----
						; attach ourself to another plug (keeping its data, if any).
						;
						; the net result is that he and we will be using ITS pipe server
						;-----
						| 'attach-to set pipe [object! | word!] (
							if word? pipe [pipe: get pipe]
							
							if liquid-lib/plug? :pipe [
								aspect: marble/valve/get-default-aspect marble

								value-backup: content pipe
								attach* aspect pipe
								
								fill pipe value-backup
								
							]
						)
						;-----
						; attach ourself to another plug (keeping its data, if any).
						;
						; the net result is that he and we will be using ITS pipe server
						;-----
						| 'connect-to set other-marble [object! | word!] (
							if word? other-marble [other-marble: get other-marble]
							
							if all [
								object? :other-marble
								in other-marble 'aspects
								in other-marble 'frame
								in other-marble 'material
								in other-marble 'valve
							][
								; this seems to be a marble... attempt to LINK our default to its default aspect
								if other-aspect: other-marble/valve/get-default-aspect other-marble [
									if aspect: marble/valve/get-default-aspect marble [
										link/reset aspect other-aspect
									]
								]
							
							]
						)
						
						| set data tuple! (
							tuple-count: tuple-count + 1
							switch tuple-count [
								1 [set-aspect marble 'label-color data]
								2 [set-aspect marble 'color data]
								2 [set-aspect marble 'border-color data]
							]
							
						) 
						
						| set data pair! (
							pair-count: pair-count + 1
							switch pair-count [
								1 [	fill* marble/material/min-dimension data ] 
								2 [	fill* marble/aspects/offset data ]
							]
						) 
						
						| set data string! (
							set-aspect marble 'label data
						) 
						
						| set data block! (
							blk-count: blk-count + 1
							; an action (by default)
							if object? get in marble 'actions [
								switch blk-count [
									1 [
										marble/actions: make marble/actions [action: make function! [event] bind/copy data marble]
									]
									
									2 [
										marble/actions: make marble/actions [alt-action: make function! [event] bind/copy data marble]
									]
								]
							]
						) 
						
						| set data [integer!] (
							fill* marble/aspects/corner data
						) 
						
						| skip 
					]
				]
				
				; give custom marbles, a chance to setup their own dialect or alter this one.
				marble/valve/dialect marble spec stylesheet
				
				vout
				;ask ""
				marble
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
			; the fun part of dialect is its tendency to call dialect on its superclass.
			; this makes the dialect polymorphic.
			;
			; in glass V3, we will retrieve the glass v1 dialecting engine which is fully polymorphic.
			;
			;
			; <TO DO>  backport the dialect() call into the gl-specify.
			;          this forces us to review all types and remove the call to dialect11
			;
			;-----------------
			dialect: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
			][
				;vin [{dialect()}]
				;vout
			]
			

			
						
			;-----------------
			;-        isolate()
			;
			; a stub for a marble to detach itself from its frame
			;-----------------
			isolate: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/isolate()}]
				if object? marble/frame [
					marble/frame/valve/detach marble/frame marble
				]
				vout
			]
			
			

			
			;-----------------
			;-        process()
			;-----------------
			; this plug returns itself, so far nothing special.
			;
			; for now there is no glass-based use of the !marble as a plug.
			process: func [
				marble data
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/process()}]
				marble/liquid: marble
				vout
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

