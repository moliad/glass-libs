REBOL [
	; -- Core Header attributes --
	title: "Glass  viewport"
	file: %viewport.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {Base class which draws marbles gui within a raster.  Currently an empty base class.}
	web: http://www.revault.org/modules/viewport.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'viewport
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/viewport.r

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
	}
	;-  \ history

	;-  / documentation
	documentation: {
		The viewport is currently pretty much an empty shell, but it will be filled up
		with quite a few features as the engine goes out of alpha.
		
		Some of the code which is currently within the Window base marble will end up here, but because I
		am still refining the whole system, I am keeping all of it combined in the window module.
		
		Eventually, a viewport will be a generic GLASS gui container, which handles its own
		coordinates offsets and refresh, so that you can split up a heavy gui into pieces.
		
		The advantage is that you will only have to refresh small parts of the gui at a time.
		
		The disadvantages of using viewports is that the graphics are clipped at their edges,
		but that can also be an advantage, like when you are using a graphics canvas within
		a paint package.
		
		Also note that the usual frame capabilities of drawing in front of their content isn't
		able to cross through to a viewport, so care must be taken in how you expect the application
		to look, when a viewport is embedded within another.
		
		Windows are a derivative of viewports and act as the outermost viewport into which
		all other viewports are embedded.  The viewports will take care of mapping
		calls to get-marble-at-offset and also mapping coordinates between marbles of different
		viewports so the display is aligned with the rest of the GUI.
		
		viewports will eventually also allow to switch rendering engines within the same OS window.
		
		One viewport might be AGG driven, and another might be OpenGL, DirectX, or a video frame 
		buffer, for example.  If the marbles are defined for every renderer, the same layout
		will end up being usable in all the different renderers.
		
		viewports will also act as containers for the default shaders to use, so that its easy
		for whole sections of a GUI to use different shaders, either while testing or by design.
		
		This means you could test out the same layout side by side in both AGG and OpenGL and
		see the reaction of both at the same time.
	}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'viewport
;
;--------------------------------------

slim/register [
	;- LIBS
;	glob-lib: slim/open/expose 'glob none [!glob]
;	liquid-lib: slim/open/expose 'liquid none [
;		!plug 
;		liquify*: liquify 
;		content*: content 
;		fill*: fill 
;		link*: link
;		unlink*: unlink
;		detach*: detach
;	]
;	
;	sillica-lib: slim/open/expose 'sillica none [
;		master-stylesheet
;		alloc-marble 
;		regroup-specification 
;		list-stylesheet 
;		collect-style 
;		relative-marble?
;		prim-bevel
;		prim-x
;		prim-label
;	]
;	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	frame-lib: slim/open 'frame none
	

	;--------------------------------------------------------
	;-   
	;- !VIEWPORT[ ]
	;
	; The view is the handle you have on a gui.  its like an OpenGL viewport, where you embed
	; graphics into an external graphic/UI container.
	;
	; things like coordinates are mapped to-from the the container to the view's internal values.
	;
	; most of the view is the same as a frame.
	;
	; views basically are the event-aware wrappers which allow the internals to react to
	; mouse and keyboard.
	;
	; note that !viewport and any derivative can ONLY be used as wrappers.  its the point of having them.
	!viewport: make frame-lib/!frame [
	
		;-    aspects[ ] same as a frame
		aspects: make aspects [ ]
		
		
		;-    material[ ] same as a frame
		material: make material []
	
		
		;-    layout-method:
		; the view is a column by default, but this can be changed after
		layout-method: 'column
		
		
		;-    view-face:
		; stores the face in which the view is displayed (remember, this may be a window face!)
		view-face: none
		
		
		;-    stream:
		;
		; stores the input stream handlers.
		;
		; this is a simple block containing functions which are executed in sequence.
		; These are allowed to interfere with the events generated for that view.
		;
		; when events first come in, they are converted to an !event.  This object is then
		; used within GLASS instead of the view event!.
		stream: none
		
		
		;-    valve []
		valve: make valve [

			type: '!viewport


			;-        style-name:
			style-name: 'view


			;-        is-viewport?:
			; tells the system that this marble can be used as a viewport and has
			; a face, ready to be linked within view somehow.
			is-viewport?: true
			
			
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

