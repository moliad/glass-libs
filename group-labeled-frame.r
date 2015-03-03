REBOL [
    ; -- Core Header attributes --
    title: "labeled glass frame"
    file: %group-labeled-frame.r
    version: 1.0.0
    date: 2015-2-4
    author: "Maxim Olivier-Adlhoch"
    purpose: {A frame with a bounding box, and optional toolbar frame}
    web: http://www.revault.org/modules/group-labeled-frame.rmrk
    source-encoding: "Windows-1252"
    note: {slim Library Manager is Required to use this module.}

    ; -- slim - Library Manager --
    slim-name: 'group-labeled-frame
    slim-version: 1.2.7
    slim-prefix: none
    slim-update: http://www.revault.org/downloads/modules/group-labeled-frame.r

    ; -- Licensing details  --
    copyright: "Copyright © 2015 Maxim Olivier-Adlhoch"
    license-type: "Apache License v2.0"
    license: {Copyright © 2015 Maxim Olivier-Adlhoch

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
        v1.0.0 - 2015-02-04
            - New style
    }
    ;-  \ history

    ;-  / documentation
    documentation: {
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
        pipe*: pipe
        link*: link 
        unlink*: unlink 
        detach*: detach 
        attach*: attach
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
        on-event
    ]
    epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
    group-lib: slim/open 'group none
    
    slim/open/expose 'bulk none [
        make-bulk
    ]
    

    
    ;-                                                                                                         .
    ;-----------------------------------------------------------------------------------------------------------
    ;
    ;- !GROUP-LABELED-FRAME[ ]
    ;
    ;-----------------------------------------------------------------------------------------------------------
    !group-labeled-frame: make group-lib/!group [
    
        ;---------------------
        ;-    aspects[ ]
        ;
        ; groups implements their own interface, and xfer to their internals, if required.
        ;
        ; note that some aspects are directly shared with their internals... 
        ;      i.e. we just put a second reference to the internal plug here.
        ;---------------------
        aspects: make aspects [
        	label: "Unnamed Frame"
        	color: (red) 
        	border-color: (blue) 
        ]
        
        
        ;-    material[ ]
        material: make material [
			border-size: 0x0
        ]


        ;--------------------------
        ;-    editor-marble:
        ;
        ; store a reference to the frame we create in order to easily collect stuff within
        ;--------------------------
        inner-frame: none
        
        ;--------------------------
        ;-    icon-pane-marble:
        ;
        ; store a reference to the icon frame we create in order to easily modify
        ; the icon bar later
        ;--------------------------
        icon-frame: none
        
        ;--------------------------
        ;-    label-marble:
        ;
        ; reference to the label being used as the label, in case we want to play with it
        ;--------------------------
        label-marble: none
        
        
       
        ;--------------------------
        ;-    content-specification:
        ; this stores the spec block we execute on setup.
        ;
        ; note that because it's declared here (within the marble) all words are bound to the 
        ; marble automatically, so assignments work.
        ;
        ; it is handled normally by a row frame.
        ;
        ; the dialect for the group itself, is completely redefined for each group.
        ;
        ; remember that the group itself is a frame, so you can set its looks, and layout mode normally.
        ;--------------------------
		; NOTE: this is composed at group creation, so it cannot be changed run-time
		content-specification: compose/deep [
			column tight 4x4  (theme-frame-color)  (theme-frame-color) [
				row tight[
					label-marble: auto-label "Group Frame" (theme-frame-label-color) left with [fill aspects/font (theme-frame-font) ]
					hstretch
					; following column vertically centers any icon-frame content.
					column stiff tight [
						vstretch
						icon-frame: row tight [
							; nothing by default, you must specify icons to add in the frame's creation spec.
						]
						vstretch
					]
				]
				;button ":-)"
				inner-frame: column tight  [ ; ( theme-frame-bg-color ) ( theme-frame-bg-color ) [
					;shadow-hseparator
					; nothing by default, you must specify marbles to add in your frame.
				]
			]
		]




       
        ;--------------------------
        ;-    spacing-on-collect:
        ;
        ; we don't want any space between group elements
        ;--------------------------
        spacing-on-collect: 0x0
        
        
        ;--------------------------
        ;-    layout-method:
        ; group is a frame... make it a column or a row
        ;--------------------------
        layout-method: 'COLUMN
        
        
        ;------------------------------------------------------------------------------
        ;-    valve []
        ;------------------------------------------------------------------------------
        valve: make valve [

            ;--------------------------
            ;-        style-name:
            ;
            ; this is the name used by default in stylesheets. (collect-style())
            ;--------------------------
            style-name: 'label-frame
        

            ;--------------------------
            ;-        bg-glob-class:
            ;-        fg-glob-class:
            ;
            ; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
            ; 
            ; you can add globs to show up in front or behind the grouped content.
            ;
            ; for a reference on how to use the
            ;--------------------------
            bg-glob-class: none
            fg-glob-class: none
            
            
            ;-----------------
            ;-        setup-style()
            ;
            ; build up the style on the fly (creating default values, for example).
            ;-----------------
            setup-style: func [
                group
            ][
                vin [{!group-labeled-frame/setup-style()}]
                vout
            ]
            
            
            ;-----------------
            ;-        group-specify()
            ;
            ; low-level group dialect
            ;
            ; to increase the 
            ;-----------------
            group-specify: func [
                group [object!]
                spec [block!]
                stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
                /local data block-count blk
            ][
                vin [{!group-labeled-frame/group-specify()}]
                block-count: 0
                
                ;vprobe spec
              ;  vprint "-----------"
                parse spec [
                    any [
                        ;here: set data skip (probe data ) :here
                        set data string! (
                            vprint "text !!!"
                            v?? data
                            ;ask "!"
                            fill* group/label-marble/aspects/label data
                        )
                    
;                        | set data tuple! (
;                            vprint "text COLOR!" 
;                            set-aspect editor-marble 'color data
;                        )
                        
						| set data block! (
							vprint "setting PANE CONTENT"
							vprobe data
							gl/layout/within/using data group/inner-frame stylesheet
						)

						| [ 'icons set data block!] (
							gl/layout/within/using data group/icon-frame stylesheet
						)
                        
                        
                        | [ 'with set data block!] (
                            vprint "SPECIFIED A WITH BLOCK"
                            do bind/copy data group 
                        )
                        
                        
;                       | 'stiff (
;                           group/stiffness: 'xy
;                           ;fill* group/material/fill-weight 0x0
;
;                       )
;                       | 'stiff-x (
;                           group/stiffness: 'x
;                           ;fill* group/material/fill-weight 0x0
;
;                       )
;                       | 'stiff-y (
;                           group/stiffness: 'y
;                           ;fill* group/material/fill-weight 0x0
;
;                       )

;                        | set data pair! (
;                            ; set the cursor
;                            
;                            vprint "PAIRS!!!"
;                            v?? data
;                            ;fill* group/material/user-min-dimension data
;                        ) 
                        
                        | skip 
                    ]
                ]
                vprint "-----------"
                ;----
                ; if there aren't any items given at this point, create an empty one... 
                ; this allows us to simply append to the system later.
                unless string? content* group/label-marble/aspects/label [
                    vprint "NO LABEL... initializing to an empty text"
                    fill* group/label-marble/aspects/label to-string content* group/label-marble/aspects/label
                ]
                vout
                group
            ]
            
            
            
            ;-----------------
            ;-        fasten()
            ;-----------------
            fasten: funcl [
                group
            ][
                vin [{!group-labeled-frame/fasten()}]
                ;--------------------------------
                ; shortcuts for simpler coding
                ;--------------------------------
                group/aspects/label: group/label-marble/aspects/label
                
                vout
            ]
        ]
    ]
]
