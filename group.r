REBOL [
	; -- Core Header attributes --
	title: "Glass group marble core style"
	file: %group.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {Setup and re-create pre-defined groups of marbles to use as a single marble.}
	web: http://www.revault.org/modules/group.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'group
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/group.r

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
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		The Group is a VERY useful base marble.  Its a hybrid frame/control, since it
		allows to merge ANY layout as if it where a single control.
		
		It is based on a frame, so it has all of a frame's methods, including all the layout stuff
		but it will initialize a new predefined-layout for you, when it it initializes.
		
		But then you are expected to merge the relevant aspects of the controls in your group within
		your own aspect, so that you end up with a single interface to many marbles.
		
		Note that in groups, you don't overide the specify() function, but rather the GROUP-SPECIFY() command
		to define your dialect.
		
		Also note that all the other user-methods are available to overide, making this a VERY flexible marble.
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'group
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
    slim/open/expose 'utils-series  none [ include ]

    
    frame-lib: slim/open 'frame none
    

    ;--------------------------------------------------------
    ;-   
    ;- GLOBALS
    ;

    
    
    ;--------------------------------------------------------
    ;-   
    ;- !GROUP[ ]
    !group: make frame-lib/!frame [
    
        ;-    aspects[ ]
        aspects: make aspects []
        
        
        ;-    material[ ]
        material: make material [border-size: 20x20]

        ;-    spacing-on-collect:
        ; when collecting marbles, automatically set their offset to this value
        ; in groups, usually you want content to be juxtaposed.
        spacing-on-collect: 5x5
        
        
        
        ;-    layout-method:
        ; most groups are horizontal
        layout-method: 'row
        
        
        
        ;-    content-specification:
        ; this stores the spec block we execute on setup.
        ;
        ; it is handled normally by frame.
        ;
        ; note that the dialect for the group itself, is completely redefined for each group.
        ;
        ; also, if you wish to assign the marbles to words, do not use set-word notation in
        ; the specification (its disabled), but assign them later in something like materialize() or stylize()
        ; using the group/collection to retrieve them.
        content-specification: none
        
        
        ;-    specified?:
        ; when specify is called the first time, this is set to true.  succeding calls to specify, will
        ; ignore content-specification allocation and go directly to group-specify
        ;
        ; this prevents the group from re-allocating the content-specification all over again!
        specified?: false
        
        
        
        ;-    valve []
        valve: make valve [

            type: '!marble


            ;-        style-name:
            style-name: 'group
        

            ;-        bg-glob-class:
            ;-        fg-glob-class:
            ; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
            bg-glob-class: none
            fg-glob-class: none

        
            ;-----------------
            ;-        specify()
            ;
            ; parse a specification block during initial layout operation
            ;
            ; groups automatically create new marble instances at specify() time.
            ;
            ; they are also responsible for calling layout setup operations providing any
            ; environment which is required by new marbles
            ;
            ; the group will look at the specification and provide a single interface
            ; to all its marbles.  it can generate the marbles before, or after the spec
            ; is managed, its really up to it.
            ;
            ; this default specify function pre-allocates our content-specification
            ; and calls the new group-specify() method.
            ;-----------------
            specify: func [
                group [object!]
                spec [block!]
                stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
                /wrapper "this is a wrapper, gl-fasten() will react accordingly"
                /local marble item pane data marbles set-word do-blk
            ][
                vin [{glass/!} uppercase to-string group/valve/style-name {[} group/sid {]/specify()}]
                
                stylesheet: any [stylesheet master-stylesheet]
                
                
                unless group/specified? [
                    group/specified?: true
                    if wrapper [
                        include group/options 'wrapper
                    ]
                    
                    ; possibly useless.
                    group/content-specification: bind/copy group/content-specification group
                    
                    ; PRE-ALLOCATE CONTENT
                    pane: regroup-specification group/content-specification 
                    new-line/all pane true
                    vprint "skipping inner pane attributes"
                    pane: find pane block!
                    v?? pane
                    
                    ; create & specify inner marbles
                    foreach item pane [
                        ;---
;                       ; store the word to set, then skip it.
;                       ; after we use set on the returned marble.
                        if set-word? set-word: pick item 1 [
                            item: next item
                        ]
                        
                        either marble: alloc-marble/using first item next item stylesheet [
                            marbles: any [marbles copy []]
                            
                            append marbles marble
                            
                            marble/frame: group
                            
                            marble/valve/gl-fasten marble

                            if set-word? :set-word [
                                set :set-word marble
                            ]
                            
                        ][
                            ; because of specification's parsing, this code should never really be reached
                            vprint ["ERROR creating new marble of type: " item " in group!"]
                        ]
                    ]
                    
                    ; add all children to our collection
                    group/valve/accumulate group marbles
                ]
                group: group/valve/group-specify group spec stylesheet  
                
                ; take this group and fasten it.
                group/valve/gl-fasten group
                
                ;------
                ; cleanup GC
                marbles: spec: stylesheet: marble: pane: item: data: none
                vout
                
                group
            ]

    
            ;-----------------
            ;-        group-specify()
            ;
            ; a specify function just for your group class.
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
                        set data tuple! (
                            set-aspect group 'color data
                        ) |
                        set data pair! (
                            fill* group/material/border-size data
                        ) |
                    ]
                ]
                vout
                group
            ]
            

            
            
            ;--------------------------
            ;-        fasten()
            ;--------------------------
            fasten: funcl [
                group [object!]
            ][
                vin "fasten()"
                ;group/valve/gl-fasten group
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

