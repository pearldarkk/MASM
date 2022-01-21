.386
.model flat, stdcall
option casemap: none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\msvcrt.inc
include C:\masm32\include\comdlg32.inc
includelib C:\masm32\lib\msvcrt.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\comdlg32.lib

.data
	NL								db		0Ah, 0
	hex								db		'0x',0
	msg								db		'Enter link to PE file: ', 0Ah, 0
	errMsg							db		'[!] Error while extracting file!', 0
	sDOSHeader						db		'[1] DOS Header: ', 0
		se_magic					db		9, 'e_magic: ', 0
		se_lfanew					db		9, 'e_lfanew: ', 0
	sPEHeader						db		'[2] IMAGE_NT_HEADERS: ', 0
		sSignature					db		9, '[2.1] Signature: ', 0
		sFileHeader					db		9, '[2.2] IMAGE_FILE_HEADER: ', 0
			sMachine				db		9, 9, 'Machine: ', 0
			sNumberOfSections		db		9, 9, 'NumberOfSections: ', 0
			sCharacteristics		db		9, 9, 'Characteristics: ', 0
		sOptionalHeader				db		9, '[2.3] IMAGE_OPTIONAL_HEADER: ', 0
			sAddressOfEntryPoint	db		9, 9, 'Address Of Entry Point: ', 0
			sImageBase				db		9, 9, 'Image Base: ', 0
			sSectionAlignment		db		9, 9, 'Section Alignment: ', 0
			sFileAlignment			db		9, 9, 'File Alignment: ', 0
			sSizeOfImage			db		9, 9, 'Size Of Image: ', 0
			sSizeOfHeaders			db		9, 9, 'Size Of Headers: ', 0
			sDataDirectory			db		9, 9, 'Data Directory: ', 0
				sExportDRVA			db		9, 9, 9, 'Export Directory RVA: ', 0
				sExportDSize		db      9, 9, 9, 'Export Directory Size: ', 0
				sImportDRVA			db		9, 9, 9, 'Import Directory RVA: ', 0
				sImportDSize		db      9, 9, 9, 'Import Directory Size: ', 0
				sResourceDRVA		db		9, 9, 9, 'Resource Directory RVA: ', 0
				sResourceDSize		db      9, 9, 9, 'Resource Directory Size: ', 0
				sExceptionDRVA		db		9, 9, 9, 'Exception Directory RVA: ', 0
				sExceptionDSize		db      9, 9, 9, 'Exception Directory Size: ', 0
				sSecurityDRVA		db		9, 9, 9, 'Security Directory RVA: ', 0
				sSecurityDSize		db      9, 9, 9, 'Security Directory Size: ', 0
				sRelocationDRVA		db		9, 9, 9, 'Relocation Directory RVA: ', 0
				sRelocationDSize	db      9, 9, 9, 'Relocation Directory Size: ', 0
				sDebugDRVA			db		9, 9, 9, 'Debug Directory RVA: ', 0
				sDebugDSize			db      9, 9, 9, 'Debug Directory Size: ', 0
				sArchitectureDRVA	db		9, 9, 9, 'Architecture Directory RVA: ', 0
				sArchitectureDSize	db      9, 9, 9, 'Architecture Directory Size: ', 0
				sReservedDRVA		db		9, 9, 9, 'Reserved Directory RVA: ', 0
				sReservedDSize		db      9, 9, 9, 'Reserved Directory Size: ', 0
				sTLSDRVA			db		9, 9, 9, 'TLS Directory RVA: ', 0
				sTLSDSize			db      9, 9, 9, 'TLS Directory Size: ', 0
				sConfigurationDRVA	db		9, 9, 9, 'Configuration Directory RVA: ', 0
				sConfigurationDSize	db      9, 9, 9, 'Configuration Directory Size: ', 0
				sBoundImportDRVA	db		9, 9, 9, 'BoundImport Directory RVA: ', 0
				sBoundImportDSize	db      9, 9, 9, 'BoundImport Directory Size: ', 0
				sIATDRVA			db		9, 9, 9, 'IAT Directory RVA: ', 0
				sIATDSize			db      9, 9, 9, 'IAT Directory Size: ', 0
				sDelayDRVA			db		9, 9, 9, 'Delay Directory RVA: ', 0
				sDelayDSize			db      9, 9, 9, 'Delay Directory Size: ', 0
				sNETDRVA			db		9, 9, 9, '.NET Directory RVA: ', 0
				sNETDSize			db      9, 9, 9, '.NET Directory Size: ', 0
	sSectionTable					db		'[3] Section Table: ', 0
		sName1						db		9, 'Name1: ', 0
		sVirtualSize				db		9, 'Virtual Size: ', 0
		sVirtualAddress				db		9, 'Virtual Address: ', 0
		sSizeOfRawData				db		9, 'Size Of Raw Data: ', 0
		sPointerToRawData			db		9, 'Pointer To Raw Data: ', 0
		ssCharacteristics			db		9, 'Characteristics: ', 0
	sExportSection					db		'[4] Export: ', 0
	sNoExport						db		9, 'No Export!', 0
		snName						db		9, 'nName: ', 0
		snBase						db		9, 'nBase: ', 0
		sNumberOfFunctions			db		9, 'Number Of Functions: ', 0
		sNumberOfNames				db		9, 'Number Of Names: ', 0
		sRVA						db		9, 'RVA: ', 0
		sOrdinal					db		9, 'Ordinal: ', 0
		sFuncName					db		9, 'Function Name: ', 0
	sImportSection					db		0Ah, '[5] Import: ', 0
		sDLLName					db		9, 'DLL Name: ', 0
		sFuncList					db		9, 'Functions List: ', 0
		sHint						db		9, 9, 'Hint: ', 0
		tOrdinal					db		9, 9, 0

.data?
	sTemp							db	9	dup(?)
	hFile							HANDLE	?
	fileName						db	512	dup(?)
	fileSize						dd		?
	hMap							HANDLE	?
	pMap							dd		?
; Import
	imRVA							dd		?
; Export
	exRVA							dd		?
	exOrdinalOffset					dd		?
	exFuncOffset					dd		?
	exNameOffset					dd		?
; Section 
	sectionHeaderOffset				dd		?
	nSection						dd		?
	nName							dd		?
	nBase							dd		?
	
.code
main PROC
	push	offset msg
	call	StdOut

	push	128
	push	offset fileName
	call	StdIn

openFile:
	push	NULL
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	NULL
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	offset fileName
	call	CreateFile
	mov		hFile, eax

	cmp		eax, INVALID_HANDLE_VALUE
	je		errExit

mapFile:
	push	NULL
	push	NULL
	push	NULL
	push	PAGE_READONLY
	push	NULL
	push	hFile
	call	CreateFileMapping
	mov		hMap, eax

	; if the map handle is valid
	cmp		eax, INVALID_HANDLE_VALUE
	je		errExit

	push	NULL
	push	NULL
	push	NULL
	push	FILE_MAP_READ
	push	hMap
	call	MapViewOfFile
	mov		pMap, eax

	; if file is mapped correctly in memory
	cmp		eax, 0
	je		errExit

extract:
	; DOS Header contains some, but most significant is e_magic contains file signature valued MZ, e_lfanew contains offset of PE Header (beginning of file)
	_DOSHeader:
		mov		edi, pMap
		assume	edi: ptr IMAGE_DOS_HEADER
		cmp		[edi].e_magic, IMAGE_DOS_SIGNATURE	; if the file is a DOS file
		jne		errExit
		push	offset sDOSHeader
		call	println

				_e_magic:					; contains magic bytes
				push	offset se_magic
				call	StdOut
				movzx	edx, [edi].e_magic			; e_magic has size dw
				push	edx
				call	printn

				_e_lfanew:					; contains offset of PE Header relative to file beginning so that loader can skip DOS stub
				push	offset se_lfanew 
				call	StdOut
				push	[edi].e_lfanew				; size dd
				call	printn
		push	offset NL
		call	StdOut

	; IMAGE_NT_HEADERS (PE Header) contains Signature, FileHeader and OptionalHeader
	_PEHeader:	
		add		edi, [edi].e_lfanew					; offset PE Header
		assume	edi: ptr IMAGE_NT_HEADERS
		cmp		[edi].Signature, IMAGE_NT_SIGNATURE ; if this is PE, Signature must contains 50h, 45h, 00h, 00h - PE\0\0
		jne		errExit
		push	offset	sPEHeader
		call	println

			_Signature:						; File Signature. If it contains NE -> 16bit NE, LE -> W3.x Virtual Device Driver, LX -> OS/2 2.0
			push	offset	sSignature
			call	StdOut
			push	[edi].Signature					; size dd
			call	printn

			_IMAGE_FILE_HEADER:				; FileHeader contains 20 bytes info about physical layout and properties of the file
			add		edi, 4 ; size of nt signature
			assume	edi: ptr IMAGE_FILE_HEADER
			push	offset sFileHeader
			call	println

				_Machine:					; model of machine
				push	offset sMachine
				call	StdOut
				movzx	edx, [edi].Machine			; size dw
				push	edx
				call	printn

				_NumberOfSections:			; must be modify if we add/delete any sections in PE file
				push	offset	sNumberOfSections
				call	StdOut
				movzx	edx, [edi].NumberOfSections	; size dw
				mov		nSection, edx
				push	edx	
				call	printn

				_Characteristics:			; contains flags check file is .exe or .dll
				push	offset	sCharacteristics
				call	StdOut
				movzx	edx, [edi].Characteristics	; size dd
				push	edx	
				call	printn

			_Optional_Header:				; contains 224 bytes, last 128 contains Data Directory
			add		edi, 14h						; sizeof image file header
			assume	edi: ptr IMAGE_OPTIONAL_HEADER
			push	offset	sOptionalHeader
			call	println

				_AddressOfEntryPoint:		; RVA of 1st instruction will be executed when PE loader about to run PE file. Can be used to divert flo of execution from the start
				push	offset sAddressOfEntryPoint
				call	StdOut
				push	[edi].AddressOfEntryPoint
				call	printn

				_ImageBase:					; pe loader will try to load the file into virtual address starting at the value at this if no other module occupied that range yet.
				push	offset sImageBase
				call	StdOut
				push	[edi].ImageBase
				call	printn
				
				_SectionAlignment:			; granularity of sections in memory. each section must start at multiple of the value at this. Leftover space mostly unused.
				push	offset sSectionAlignment
				call	StdOut
				push	[edi].SectionAlignment 
				call	printn

				_FileAlignment:				; granularity of sections in file. Leftover space is unused/undefined.
				push	offset sFileAlignment
				call	StdOut
				push	[edi].FileAlignment
				call	printn

				_SizeOfImage:				; Overall size of PE image in memory (sum of headers + sections aligned to SectionAlignment)
				push	offset sSizeOfImage
				call	StdOut
				push	[edi].SizeOfImage
				call	printn

				_SizeOfHeaders:				; Sizeof headers + section table. Filesize - sizeof sections.= offset of 1st section in file
				push	offset sSizeOfHeaders
				call	StdOut
				push	[edi].SizeOfHeaders
				call	printn

				_DataDirectory:				; Last 128 bytes. Array of 16 IMAGE_DATA_DIRECTORY
				push	offset sDataDirectory
				call	println
				add		edi, 60h			; address of IMAGE_DATA_HEADERS 224 - 128

					_ExportDirectory:
					push	offset sExportDRVA
					call	StdOut
					mov		edx, dword ptr [edi]
					mov		exRVA, edx
					push	edx
					call	printn
					push	offset sExportDSize
					call	StdOut
					push	dword ptr [edi + 4h]
					call	printn
					_ImportDirectory:
					push	offset sImportDRVA
					call	StdOut
					mov		edx, dword ptr [edi + 8h]
					mov		imRVA, edx
					push	edx
					call	printn
					push	offset sImportDSize
					call	StdOut
					push	dword ptr [edi + 0Ch]
					call	printn

					_ResourceDirectory:
					push	offset sResourceDRVA
					call	StdOut
					push	dword ptr [edi + 10h]
					call	printn
					push	offset sResourceDSize
					call	StdOut
					push	dword ptr [edi + 14h]
					call	printn
					_ExceptionDirectory:
					push	offset sExceptionDRVA
					call	StdOut
					push	dword ptr [edi + 18h]
					call	printn
					push	offset sExceptionDSize
					call	StdOut
					push	dword ptr [edi + 1Ch]
					call	printn

					_SecurityDirectory:
					push	offset sSecurityDRVA
					call	StdOut
					push	dword ptr [edi + 20h]
					call	printn
					push	offset sSecurityDSize
					call	StdOut
					push	dword ptr [edi + 24h]
					call	printn

					_RelocationDirectory:
					push	offset sRelocationDRVA
					call	StdOut
					push	dword ptr [edi + 28h]
					call	printn
					push	offset sRelocationDSize
					call	StdOut
					push	dword ptr [edi + 2Ch]
					call	printn

					_DebugDirectory:
					push	offset sDebugDRVA
					call	StdOut
					push	dword ptr [edi + 30h]
					call	printn
					push	offset sDebugDSize
					call	StdOut
					push	dword ptr [edi + 34h]
					call	printn

					_ArchitectureDirectory:
					push	offset sArchitectureDRVA
					call	StdOut
					push	dword ptr [edi + 38h]
					call	printn
					push	offset sArchitectureDSize
					call	StdOut
					push	dword ptr [edi + 3Ch]
					call	printn

					_ReservedDirectory:
					push	offset sReservedDRVA
					call	StdOut
					push	dword ptr [edi + 40h]
					call	printn
					push	offset sReservedDSize
					call	StdOut
					push	dword ptr [edi + 44h]
					call	printn

					_TLSDirectory:
					push	offset sTLSDRVA
					call	StdOut
					push	dword ptr [edi + 48h]
					call	printn
					push	offset sTLSDSize
					call	StdOut
					push	dword ptr [edi + 4Ch]
					call	printn

					_ConfigurationDirectory:
					push	offset sConfigurationDRVA
					call	StdOut
					push	dword ptr [edi + 50h]
					call	printn
					push	offset sConfigurationDSize
					call	StdOut
					push	dword ptr [edi + 54h]
					call	printn

					_BoundImportDirectory:
					push	offset sBoundImportDRVA
					call	StdOut
					push	dword ptr [edi + 58h]
					call	printn
					push	offset sBoundImportDSize
					call	StdOut
					push	dword ptr [edi + 5Ch]
					call	printn

					_IATDirectory:
					push	offset sIATDRVA
					call	StdOut
					push	dword ptr [edi + 60h]
					call	printn
					push	offset sIATDSize
					call	StdOut
					push	dword ptr [edi + 64h]
					call	printn

					_DelayDirectory:
					push	offset sDelayDRVA
					call	StdOut
					push	dword ptr [edi + 68h]
					call	printn
					push	offset sDelayDSize
					call	StdOut
					push	dword ptr [edi + 6Ch]
					call	printn

					_NETDirectory:
					push	offset sNETDRVA
					call	StdOut
					push	dword ptr [edi + 70h]
					call	printn
					push	offset sNETDSize
					call	StdOut
					push	dword ptr [edi + 74h]
					call	printn
	sub		edi, 60h						; back to 1st offset of PE Header
	push	offset NL
	call	StdOut

	_SectionTable:							; Array of IMAGE_SECTION_HEADER
	add		edi, sizeof IMAGE_OPTIONAL_HEADER
	assume	edi: ptr IMAGE_SECTION_HEADER
	mov		sectionHeaderOffset, edi
	push	offset sSectionTable
	call	println
	
	mov		ebx, nSection					; Check if the file has any sections
	test	ebx, ebx
	je		_ExportSection

		_IMAGE_SECTION_HEADER:					; main contents of file
		test	ebx, ebx
		jz		_ExportSection
		dec		ebx

			_Name1:								; 8 bytes Label, can be blank, not have \0 as string
			push	offset sName1
			call	StdOut
			push	edi
			call	StdOut
			push	offset NL
			call	StdOut

			_VirtualSize:						; The actual size of section data, the real memory loader allocates
			push	offset sVirtualSize
			call	StdOut
			push	dword ptr [edi + 8h]
			call	printn

			_VirtualAddress:					; RVA of section
			push	offset sVirtualAddress
			call	StdOut
			push	[edi].VirtualAddress
			call	printn

			_SizeOfRawData:						; Size of section data in file on disk, rounded up aligned by compiler
			push	offset sSizeOfRawData
			call	StdOut
			push	[edi].SizeOfRawData
			call	printn
		
			_PointerToRawData:					; Offset from the file beginning to section data. If 0 -> section data not contained 
			push	offset sPointerToRawData
			call	StdOut
			push	[edi].PointerToRawData
			call	printn

			__Characteristics:
			push	offset ssCharacteristics
			call	StdOut
			push	[edi].Characteristics
			call	printn
		add		edi, 28h
		push	offset NL
		call	StdOut
		jmp		_IMAGE_SECTION_HEADER

	_ExportSection:							; DLL export functions by name/ordinal only (dw unique identifies a function in a DLL.
	push	offset sExportSection
	call	println
	cmp		exRVA, 0
	jnz		_Export
	push	offset sNoExport
	call	println
	jmp		_ImportSection
	
		_Export:							
		push	nSection
		push	sectionHeaderOffset
		push	exRVA
		call	RVAtoOffset
		mov		edi, eax
		add		edi, pMap
		assume	edi: ptr IMAGE_EXPORT_DIRECTORY

			_nName:							; Internal name of module in case user changed name of file
			push	nSection
			push	sectionHeaderOffset
			push	[edi].nName
			call	RVAtoOffset
			add		eax, pMap
			mov		ebx, eax
			push	offset snName
			call	StdOut
			push	ebx
			call	println

			_nBase:							; Starting ordinal number
			push	offset snBase
			call	StdOut
			mov		edx, [edi].nBase
			mov		nBase, edx
			push	edx
			call	printn

			_NumberOfFunctions:				; total functions that are exported by this module
			push	offset sNumberOfFunctions
			call	StdOut
			push	[edi].NumberOfFunctions
			call	printn

			_NumberOfNames:					; total symbols exported by name. If export by ordinal, it may not needed.
			push	offset sNumberOfNames
			call	StdOut
			mov		edx, [edi].NumberOfNames
			mov		nName, edx
			push	edx
			call	printn

			_AddressOfNameOrdinal:
			push	nSection
			push	sectionHeaderOffset
			push	[edi].AddressOfNameOrdinals
			call	RVAtoOffset
			add		eax, pMap
			mov		exOrdinalOffset, eax

			@noOrdinalExport:
				_AddressOfFunctions:
				push	nSection
				push	sectionHeaderOffset
				push	[edi].AddressOfFunctions
				call	RVAtoOffset
				add		eax, pMap
				mov		exFuncOffset, eax
				
				_AddressOfNames:
				push	nSection
				push	sectionHeaderOffset
				push	[edi].AddressOfNames
				call	RVAtoOffset
				add		eax, pMap
				mov		exNameOffset, eax

			@nextExport:
				cmp		nName, 0
				jng		_ImportSection

				_RVA:
				push	offset sRVA
				call	StdOut
				mov		eax, exOrdinalOffset
				xor		ebx, ebx
				mov		bx, [eax]
				push	ebx						; save ebx
				shl		ebx, 2
				add		ebx, exFuncOffset
				push	dword ptr [ebx]
				call	printnum 

				_Ordinal:
				push	offset sOrdinal
				call	StdOut
				pop		ebx						; pop to ebx
				add		ebx, nBase
				push	ebx
				call	printnum

				_Name:
				push	offset sFuncName
				call	StdOut
				mov		edx, dword ptr exNameOffset
				push	nSection
				push	sectionHeaderOffset
				push	dword ptr [edx]
				call	RVAtoOffset
				add		eax, pMap
				push	eax	
				call	println
			dec		nName
			add		exNameOffset, 4			; next name
			add		exOrdinalOffset, 2			
			jmp		@nextExport

	_ImportSection:
	push	offset sImportSection
	call	println
	push	nSection
	push	sectionHeaderOffset
	push	imRVA
	call	RVAtoOffset						; calculate offset

	mov		edi, eax
	add		edi, pMap
	assume	edi: ptr IMAGE_IMPORT_DESCRIPTOR

		@nextImportDLL:
		cmp		[edi].OriginalFirstThunk, 0
		jne		_Import
		cmp		[edi].TimeDateStamp, 0
		jne		_Import
		cmp		[edi].ForwarderChain, 0
		jne		_Import
		cmp		[edi].Name1, 0
		jne		_Import
		cmp		[edi].FirstThunk, 0
		jne		_Import
		jmp		_CloseHandle			; no imports left

		_Import:
			push	nSection
			push	sectionHeaderOffset
			push	[edi].Name1
			call	RVAtoOffset
			mov		ebx, eax
			add		ebx, pMap

			_NameOfDLL:
			push	offset sDLLName
			call	StdOut
			push	ebx
			call	println
			
			push	nSection
			push	sectionHeaderOffset
				@byOriginalFirstThunkOrbyFirstThunk:
				cmp		[edi].OriginalFirstThunk, 0
				jne		@byOriFirstThunk
					@byFirstThunk:
					push	[edi].FirstThunk
					jmp		@calc
					@byOriFirstThunk:
					push	[edi].OriginalFirstThunk
			@calc:
			call	RVAtoOffset
			add		eax, pMap
			mov		esi, eax

			_FunctionsList:					; IMAGE_IMPORT_BY_NAME
			push	offset sFuncList
			call	println
			push	edi

				_Function:
				cmp		dword ptr [esi], 0
				je		@nextDLL
					@byNameorbyOrdinal:
					test	dword ptr [esi], IMAGE_ORDINAL_FLAG32
					jnz		@byOrdinal

					@byName:
					push	nSection
					push	sectionHeaderOffset
					push	dword ptr [esi]
					call	RVAtoOffset
					mov		edi, eax
					add		edi, pMap
					assume	edi: ptr IMAGE_IMPORT_BY_NAME

						_Hint:				; Index into Export Address Table of DLL
						push	offset sHint
						call	StdOut
						movzx	edx, [edi].Hint
						push	edx
						call	printnum

						__Name1:
						push	offset sName1
						call	StdOut
						lea		edx, [edi].Name1
						push	edx
						call	println
						jmp		@nextImport

					@byOrdinal:
					push	offset tOrdinal
					call	StdOut
					mov		edx, dword ptr [esi]
					and		edx, 0FFFFh
					push	edx
					call	printn
			
				@nextImport:
				add		esi, 4
				jmp		_Function
			
			@nextDLL:
			pop		edi
			add		edi, sizeof IMAGE_IMPORT_DESCRIPTOR
			jmp		@nextImportDLL

	_CloseHandle:									; Close handle, unmap, exit
	push	pMap
	call	UnmapViewOfFile
	push	hFile
	call	CloseHandle
	push	hMap
	call	CloseHandle
	ret

errExit:
	push	hFile
	call	CloseHandle
	push	hMap
	call	CloseHandle
	push	offset errMsg
	call	StdOut
	ret

main ENDP

println PROC	; print with linefeed
	push	ebp
	mov		ebp, esp
	push	ecx
	push	[ebp + 8h]
	call	StdOut
	push	offset NL
	call	StdOut
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		4h
println ENDP

itoa PROC	; para1 = val, para2 = string
	push	ebp
	mov		ebp, esp
	push	edi
	push	ebx
	push	edx
	push	ecx
	mov		ebx, 10h
	mov		eax, [ebp + 0Ch]
	mov		edi, [ebp + 8h]
	clearstring:
		push	eax
		cld
		mov		ecx, 9
		mov		al, 0
		rep		stosb
		pop		eax
	dec		edi
	@nxtChr:
		dec		edi
		xor		edx, edx
		div		ebx
		cmp		edx, 0Ah
		jl		@xor30
		add		edx, 37h
		jmp		@continue
		@xor30:
		xor		edx, 30h
		@continue:
		mov		byte ptr [edi], dl
		test	eax, eax			
		jnz		@nxtChr
	mov		eax, edi
	pop		ecx
	pop		edx
	pop		ebx
	pop		edi
	mov		esp, ebp
	pop		ebp
	ret		8h
itoa ENDP

printn PROC
	push	ebp
	mov		ebp, esp

	push	offset hex
	call	StdOut
	push	[ebp + 8] ; value
	push	offset sTemp ; value as string
	call	itoa
	push	eax
	call	println

	mov		esp, ebp	
	pop		ebp
	ret		4
printn ENDP

printnum PROC
	push	ebp
	mov		ebp, esp

	push	offset hex
	call	StdOut
	push	[ebp + 8] ; value
	push	offset sTemp ; value as string
	call	itoa
	push	eax
	call	StdOut

	mov		esp, ebp	
	pop		ebp
	ret		4
printnum ENDP

RVAtoOffset PROC
	push	ebp
	mov		ebp, esp
	push	edi
	push	edx
	mov		edx, [ebp + 8h]					; RVA
	mov		edi, [ebp + 0Ch]				; offset section Header
	assume	edi: ptr IMAGE_SECTION_HEADER
	mov		ecx, [ebp + 10h]				; number of sections

		@sectionIterate:
		test	ecx, ecx
		jz		@return
			cmp		edx, [edi].VirtualAddress	; if RVA of current is less -> jump next section
			jl		@nextSection
				mov		eax, [edi].VirtualAddress
				add 	eax, dword ptr [edi + 8h]
				cmp		edx, eax					; if RVA is greater than sectionHeader + virtualSize ->  next
				jge		@nextSection
					mov		eax, [edi].VirtualAddress
					sub		edx, eax
					mov		eax, [edi].PointerToRawData 
					add		eax, edx					; Offset = Ptr - VirtualAddress + PointerToRawData
					jmp		@return
		@nextSection:
		add		edi, sizeof IMAGE_SECTION_HEADER
		dec		ecx
		jmp		@sectionIterate
		mov		eax, edx
	@return:
	pop		edx
	pop		edi
	mov		esp, ebp
	pop		ebp
	ret		0Ch
RVAtoOffset ENDP
end main