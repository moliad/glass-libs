REBOL [
	; -- Core Header attributes --
	title: "Glass icon library management"
	file: %icons.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {Run-time re-loadable icon loading system.  Can change icon sets.}
	web: http://www.revault.org/modules/icons.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'icons
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/icons.r

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
		v1 - 2013-09-17
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		This library acts as a single entry point for entire sets of icons.
		
		Every icon is loaded as a liquid plug so linking the images within other glass systems is very easy.
		
		If you reload a new icon set, the images will update in real-time in the glass ui.
		
		Most image using styles will even resize automatically based on these new image sizes!
	}
	;-  \ documentation
]


;- SLIM/REGISTER
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

	
	;- 
	;- GLOBALS
	
	;--------------------------
	;-    default-style:
	default-style: 'default
	
	;--------------------------
	;-    default-size:
	default-size: 32 ; MUST be an integer!
	
	;--------------------------
	;-    default-set:
	default-set: 'glass
	
	;--------------------------
	;-    root-path
	root-path: what-dir
	
	;--------------------------
	;-     encapped-icons?:
	encapped-icons?: value? 'encapped-glass-icon-library
	
	
	
	;-    default-icon:
	; this is the default glass marble image
	default-icon: make image! [32x32 #{
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000009BB3B9
7B96AE6E8EB06B8EB3799BBB8FAEC3ADC4C8C9D8D1000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000009CB3BD
5B7FB54774BD4B7EC84E89D24E88D1508BD15691D76396D27DA7D0ACC6D5
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000D1E2D8
80A0C24F7FC6548CCC5F96D4619CDD639DE35D9CDE60A0E266A4E768A3E4
6AA5E770A5E598BEDCC9DBD5000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
D6E5DE7FA2CD5388D16198D769A0DB6AA4E067A4E566A2E85FA1E964A4EB
68A6EB6BA9EC6DACEC6EAEEF72AEF097C2E8CCDDD4000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000009CB5CE5B8CD4679AD975A8E180B4EB7EB3EE74AEEB63A2E6
5C9EE561A1E561A4E966A9EE6CACEF6FB0F274B5F479B7F9A4CAE8000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000C4D6D46C97CF6698DB7AAAE492BFF095C3F28FBFF1
83BAEF63A3E95FA0E863A3EB61A6ED64A7ED66AAEE6CADF171B3F576B8FB
86C2FCB4CED66B8D8E171719000000000000000000000000000000000000
000000000000000000000000000000A1BBD26596D670A2E08DBCF19FCBF7
A2CEF59AC8F589BEF560A4F05CA4F061A6F162A7F264AAF166A8EF68ACF2
6FB1F678B7F981C2FF9ECCEC5F7A7C566C6F526A6B1B1C1F151618000000
000000000000000000000000000000000000D8E8DF89AAD2679BDB79ACE4
97C3F5A4CFF9AED8F8A1CFF97DB9F55BA1F15BA4F05FA6F061A6F364A9F3
67AAF167ABF16EB0F774B5F77EBDFB92CBFC80979A5C75765973745A7676
171719161618000000000000000000000000000000000000D0E1DF7FA6D3
6B9EDD7CAFEB94C3F59ECBF7A1CFF998C9FA74B0F35B9FEF5FA2EC62A5EE
65A7F365A9F565ABF367AAEE6AACF472B4F97CBEFC90CDFF98B4C2597072
576D6F5971733E4C4F1F1E211D1C1F1A1A1E19191B000000000000000000
C9DDDB7DA6D46EA2DE77ABE88ABBEF93C3F291C1F584BAF563A5ED62A7F0
5699E05C9FEC65A5F163A8F262A7F263A7EE69ACF272B5F97FC0FE8DCCFF
93B8CC617B7F54686A4C5C5F4D5F623A46491E1F221D1D201D1D20000000
000000000000CADFDD83A9D474A6DF6EA8E47BB1E984B7EB80B5EE6BA8EC
559CE75D9FE85499E4589EE85CA3EC60A4EE65A6EF65A7EE69ACF372B5F9
80C2FD8BCDFF8CB5CF72929D607A82566B704451544F6264222226212125
2021241E1E22000000000000D4E7E18AAED57AA8E06BA6E36DA7E470A8E7
6CA6E7579BE65097E65A9AE55FA0E75EA1EC5CA0EC60A3ED66A5ED67A6EE
69ACF274B6FA82C4FE8CCCFF88B2CE7CA0B57292A5678392566A744F6267
383F4328282C26262A232327000000000000E2F1E997B7D479A9DF75A8E0
69A4E2629FE25C9BE25296E25898E45D9DE65C9FE85C9FEC5EA0EC62A3ED
67A5F166A9EE6CB0F478BAFA86C7FF88C7FE89B5D182ABC77DA3BE7799B3
6D8CA35C7280434D552E2E332D2E3229292E000000000000000000B2CAD5
7CA8DA7BAAE273A7E562A0E15596DD5395E05495E45A99E65A9BE95C9FE8
5DA1E963A3F068ABF46DADF072B2F57EBFFC88C5FF89C4F696C9DD86B4D3
7EABCC7EA5C5789CB86C89A05A6F7E3B4047323338303035000000000000
000000D6E5E28BAED17AAEE477AAE676A9E869A3E6609BDF5D99E35A99E4
5A9DE75DA1E862A2E76CABF16FAEF470AFF279B8FA81C1FF79B5F6AAE2F3
A6DBE88DC0DF7DADD57BA6CA7DA1C27698B36A859A4C576335353C34353A
000000000000000000000000B3C8CE7DA9D47AB0E978ABE673AAE76CA6E8
69A0E564A0E563A3E766A3E969A6E96FACED71B0F378B7FA7FC0FD79B3ED
8EC9F3B9F1F0ACE3EA94C8E27DAFD979A6CD7BA1C2799BB97291A95D7285
3F454D36373C000000000000000000000000E0F2E89CB2B877A0CB7BB0E5
76AFE874ACEC6FA8E96CA6EB6AA6ED6BA9EC6DACEF74B2F47AB9FC7BB9F3
69A0D982BAE8BFF3F5B9EFEFADE2E794C6DE7DAED775A3CC769CBD779AB7
7494AE677F974D57653A3B40000000000000000000000000010101D3E5DC
9AAAAF7391AF73A1CC74A9E172ADE973ADF076B0F273AFEE71B0EE70A7D6
618AB15480AF78B1DEC0F6F7BEF1F1B3EAEAA7DADF8DBCD67AA8D0739FC7
7397B87595B17392AC6B869D58687A434952000000000000000000000000
0403045A7173B2C8C1ABBDBE7D929E67829660839C6387A75C83A35F89AE
5471883C4B5B4C6E9B8EC8E6BAF0F3BBEFF0B4EAE9ABDEE099C8D583AECE
75A2CA6F98BF6F91B27190AA708DA76C87A05F7487515C6B000000000000
000000000000030303586F71617E805E787AA2B7B696A8AB717F825B6669
5159654F5E6C4E5F756992BE97CEE3A6D9E2ABE0E5AADEE3A2D4DB96C4D4
85B0CC78A2C8719BC56B92BA6C8EB06E8BA76F8BA56A849D647A90657D93
0000000000000000000000000000002323273D4C4F638182546B71607987
56697645597049668F516F996284A8739EBD7DABC78AB8CE93C3D393C1D0
8CB7CB82ACC47AA2C2739AC06B91BA698EB46A8BAC6D89A56E89A26C87A0
69839B7291AD0000000000000000000000000000001C1C1F212125495D5E
3A484E44545E4A5A664C5F74526A895E7B9B6B8DAF6D91AF6A90AE7198B5
78A0BA7AA1BB789EB97297B46B8FB16688AC6688AC6686A766819E677F96
677F966881986F8BA67FA6C600000000000000000000000000000018181B
22222618191B18191B2B3138353D443E485347525F576674607487596E85
5268825A7490607C9763809D617C995F79955D76925F7894607A97617994
5E71865B687A55627161768A7CA1C18CBAE0000000000000000000000000
00000000000025252918181A1516181D1D1F21212533384035383F34343A
39393E3D3E4444465049505D4B55664D586A4D56654F5766515D6D566477
576779576578545F6E505B674E576353616F779AB88CBAE0000000000000
00000000000000000000000000000000000012121319191C1E1E20353C44
3A404831313637383D3C3C4240404744444B46474E48485047485047484F
4B505A525C695A697A5B6C7C5563723D3E44464C565565758CBAE08CBAE0
000000000000000000000000000000000000000000000000000000141517
1B1C1E1F1F22404B542D2D3333343938383E3B3B423F404642434A44454C
45464D45464E525A6644454C5561703F3F463D3D443B3B424D596761798F
8CBAE08CBAE0000000000000000000000000000000000000000000000000
0000000000001314164E64684F636854676F566972556873566775515E6A
535F6C607585617585698295708DA47493AE657D93657C92647B9162798F
60778D000000000000000000
} #{
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFB5
755A335772B2FDFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFA9
24000000000000001EA0
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFF7
5A000000000000000000
000054F4FFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FD450000000000000000
00000000003CFAFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFF7200000000000000
000000000000000069FF
FFFFFFFFFFFFFFFFFFFF
FFFFFFDC030000000000
00000000000000000000
03CBFCFFFFFFFFFFFFFF
FFFFFFFFFF6600000000
00000000000000000000
00000053F6FAFDFFFFFF
FFFFFFFFFFFFFD120000
00000000000000000000
000000000008E9F5F8FB
FEFFFFFFFFFFFFFFD600
00000000000000000000
0000000000000000C1EE
F1F5FBFEFEFFFFFFFFFF
B8000000000000000000
00000000000000000000
9EE4ECF0F5FAFCFEFFFF
FFFFB500000000000000
00000000000000000000
00008ACEDAE7F0F5FAFC
FDFFFFFFD00000000000
00000000000000000000
0000000077A2B4CEE4EE
F7FBFDFFFFFFF7090000
00000000000000000000
0000000000015D7187A5
C7E0EFF9FCFEFFFFFF4E
00000000000000000000
000000000000000B384B
5C769FC2E1F3F8FCFFFF
FFC10000000000000000
00000000000000000012
223041587AA2CAE7F3FB
FFFFFFFF4E0000000000
00000000000000000000
04151F2C3B4D6886AFD6
EBF8FFFFFFFFEE230000
00000000000000000000
00010F162232404F687E
9DC5E5F6FFFFFFFFFFDE
2C000000000000000000
0000020D131E2E3E4A5B
71879FBFE0F6FFFFFFFF
FFFDED65060000000000
0000010C1719202E414D
57667C90A7C4E4F8FFFF
FFFFFFFDF9F6D2733110
00060E273B3731313B48
565E6977889FB5CEE9FA
FFFFFFFFFFFEFBF7F3EA
D4BA90645059625A5554
5B666D75838D9CB1C3D7
ECFAFFFFFFFFFFFEFDF9
F7F3EADBC4A38988918B
8281848A929AA2AAB7C6
D5E2F0FAFFFFFFFFFFFF
FDFBFAF7F3EFE6D7CAC9
C8BFB4B4B5B9BFC2C7CF
D6DDE7EEF6FCFFFFFFFF
FFFFFFFDFBF9F9F6F4F2
EEEBE5E1DEDCDDDEE2E6
E8EBEFEDF1F9FCFDFFFF
FFFFFFFFFFFFFEFBFBF9
F8F9F6F3F1F0EFEEEEF0
F3F5F6F7F9F8F8FDFEFF
FFFFFFFFFFFFFFFFFFFF
FDFCFBFDFCFAF9F8F8F9
F8FAFAFDFCFDFDFDFCFE
FFFFFFFFFFFFFFFFFFFF
FFFFFFFDFDFDFDFDFDFC
FCFBFBFAFBFDFEFEFEFE
FEFFFFFF
}]
		
		
		
	*fallback: 'marble
		
		
	;-    collection:
	;
	; this contains all the current icon sets being used.
	;
	; structure: 
	;
	;     collection: [ set [ icon-name plug!  icon-name plug!  ... ] set [...] ... [
	;
	collection: []
	
	
	;-  
	;- FUNCTIONS
	;-
	;-----------------
	;-    channel-copy()
	;-----------------
	channel-copy: func [
		raster [image!]
		from [word!]
		to [word!]
		/into d
		/local pixel i b p 
	][	
		b: to-binary raster
		
		d: to-binary any [d raster]
		
		from: switch from [
			red r [3]
			green g [2]
			blue b [1]
			alpha a [4]
		]
	
		to: switch to [
			red r [3]
			green g [2]
			blue b [1]
			alpha a [4]
		]
	
		either (xor from to) > 4 [
			; when going to/from alpha we need to switch the value (rebol uses transparency not opacity)
			repeat i to-integer (length? raster)  [
				p: i - 1 * 4
				poke d p + to to-char (255 - pick b p + from)
			]
		][
			repeat i to-integer (length? raster)  [
				p: i - 1 * 4
				poke d p + to to-char pick b p + from
			]
		]
		d: to-image d
		d/size: raster/size
		d
	]
	
	
	;-----------------
	;-    parse-set-folder()
	;
	; given a path to a folder, return a block structure which lists all the available icons in the set.
	; 
	; the parser ignores all files except for .png and .iconset files.
	; 
	; the iconset files are opened, and may be decompressed if a special flag within the header.
	;
	;
	; NOTE: when a block is given, its the list of icons
	;
	; <TO DO>
	;	-support .iconset files
	;   -support compression (optional) in .iconset files
	;   -support system icons via routines.
	;-----------------
	parse-set-folder: func [
		path [file! block!]
		/local item list icons ext size digit digits to name name-end blk
	][
		vin [{parse-set-folder()}]
		
		icons: copy []
		either block? path [
			list: sort path
		][
			list: sort read path
		]
		
		digit: charset "0123456789"
		digits: [some digit]
		
		
		foreach item list [
			v?? item
			
			parse item [
				name:
				some [
					name-end: "-" size: digits to:".png" end (
						;print ["found an icon" copy/part name name-end "of size:" copy/part size to]
						name: copy/part name name-end
						either blk: select icons name [
							append blk to-integer copy/part size find size "."
						][
							append icons name
							append/only icons reduce [to-integer copy/part size find size "."]
						]
					)
					| skip
				] 
			]
		]
		
		vout
		
		icons
	]
	
	
	;-----------------
	;-    safe-icon-name()
	;-----------------
	safe-icon-name: func [
		name [string! word!]
		/local new
	][
		;vin [{safe-icon-name()}]
		new: either string? name [
			to-word replace/all name " " "-"
		][
			name
		]
		;vout
		new
	]
	
	
	;--------------------------
	;-    load-single-icon-image()
	;--------------------------
	; purpose:  if you want to load a single icon from the icon lib in a specific size.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    usefull for using some icons at large rez without loading ALL of them.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	load-single-icon-image: funcl [
		name [word! issue! string!]
		/style sname [word!] "use a different style than the default look for this set."
		/size width [integer!] "specify a different size than the default"
	][
		vin "load-single-icon-image()"
		load-icons/only/style/size/as (reduce [ name ]) sname  width (set-name: to-word rejoin ["set-" random 1000000 "-" random 1000000])
		img: get-icon/image/set (safe-icon-name name) set-name
		;?? name
		;?? sname
		;?? width
		;probe img/size
		vout
		img
	]
	
	
	;-----------------
	;-    load-icons()
	;
	; <TO DO> fallback image handling
	;-----------------
	load-icons: func [
		/set set-name [word!] "the name of the icon set to load"
		/style name [word! none!] "use a different style than the default look for this set."
		/size width [integer! none!] "specify a different size than the default"
		/only icons [word! block!] "only load the given icons, not the whole set"
		/as new-set-name [word!] "changes the name when storing a loaded set into the icon collection, so you can two sets with different-scaling or style in ram"
		
		;---
		; the following is deprecated, permits un-encapable applications
		; /path folder [file!] "the root folder in which to find the icon sets. It MUST contain a folder called default or else, you will have to be very carefull in refering to all sets by name..."
		;---
		/local icon sizes img plug rgb alpha blk icon-lib folder img-name
	][
		vin [{load-icons()}]
		; normalize parameters
		style: any [name default-style]
		width: any [width default-size]
		set-name: any [set-name default-set]
		folder: rejoin [root-path "icons/" set-name "/" style "/"]
		
		; make sure the icon set really exists
		either any [
			all [
				encapped-icons? ;use encapped images instead of disk versions.
				icon-lib: select encapped-glass-icon-library to-word rejoin  [ set-name "-" style ]
			]
			dir? folder
		][
			vprint "valid input"
			set-name: any [new-set-name set-name]
			
			if encapped-icons? [
				;vprobe length? icon-lib
				;vprobe extract icon-lib 2
				;vprobe icon-lib
				;vprobe type? icon-lib/1
				;vprobe type? icon-lib/2
				;vprobe type? icon-lib/3
				;vprobe type? icon-lib/4
			]
			
			
			; reuse or create a set ( a bit of duplication when encapped, but not that much of an issue)
			set: any [
				select collection set-name
				last append collection reduce [set-name copy []]
			]
			
			
		
			; load image files and dump them in container plugs
			either encapped-icons? [
				vprint "Icons where encapped"
				blk: parse-set-folder extract icon-lib 2
			][
				vprint "Icons where not encapped"
				blk: parse-set-folder read folder
			]
			
			;vprobe blk
			
			foreach [icon sizes] blk [
				;?? icon
				;?? icons
				if any [
					not only
					find icons safe-icon-name icon
				][
					either find sizes width [
						;vprint "loading icon directly"
						; load the icon directly
						img-name: to-file rejoin [ icon "-" width ".png"]
						
						img: either encapped-icons? [
							select icon-lib img-name
						][
							load join folder img-name
						]
					][
						;vprint "scaling icon"
						;vprint width
						; missing icon size.
						; load the largest icon and resize it (KEEPING ITS ALPHA CHANNEL!).
						;probe "didn't find an appropriate icon"
						
						img-name:  rejoin [ "" icon "-" last sizes ".png"]
						
						;v?? img-name
						
						img: either encapped-icons? [
							;vprobe extract icon-lib 2
							;vprint type? select icon-lib to-file img-name
							select icon-lib to-file img-name
						][
							load join folder img-name
						]
						alpha: channel-copy img 'alpha 'red
						
						img: draw width * 1x1 compose [image img 0x0 (width * 1x1)]
						alpha: draw width * 1x1 compose [image alpha 0x0 (width * 1x1)]
						img: channel-copy/into alpha 'red 'alpha img
					]
					
					
					; do we replace or add a new icon
					either plug: select set safe-icon-name icon [
						;probe "REPLACING ICON"
						fill* plug img
					][
						append set reduce [ safe-icon-name icon   liquify*/fill !plug img ]
					]
				]	
			]
		][
			to-error rejoin ["icons/load-icons(): required set doesn't exist at " folder]
		]
		vout
	]
	
	
	;-----------------
	;-    icon-label()
	;-----------------
	icon-label: func [
		name [word! string! issue!]
	][
		vin [{icon-label()}]
		name: to-string name
		
		;print "icon label!"
		;probe name
		
		replace/all name "_" " "
		
		vout
		name
	]
	
	
	
	;-----------------
	;-    get-icon()
	;
	; we attempt to get an image from the collection.
	;
	; if it doesn't exist, we return a fallback icon (a blue marble) 
	;-----------------
	get-icon: funcl [
		name [word!]
		/set set-name
		/image "returns the image, not the plug, of the icon"
		;/local plug icon
	][
		vin [{get-icon()}]
				
		;probe extract collection 2
		set: select collection any [set-name default-set]
		
		
		plug: any [
			select set name
			select set *fallback
		]
		icon: either image [
			content* plug
		][
			plug
		] 		
		
		
		vout
		icon
	]
	
	
	
	
]