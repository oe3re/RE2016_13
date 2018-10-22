INCLUDE Irvine32.inc
INCLUDE macros.inc

;//----------------------------------------------------------------------------------------
buffer_size = 1	;//Velicina bafera
drawDelay = 50	;//Kasnjenje izmedju sukcesivnih iscrtavanja
square = 219	;//Tip simbola koji se crta, njegova ASCII vrednost u decimalnim brojevima
;//----------------------------------------------------------------------------------------
;//Definisanje velicine prozora
xmin = 0	;//leva ivica
xmax = 49	;//desna ivica
ymin = 0	;//gornja ivica
ymax = 29	;//donja ivica
;//----------------------------------------------------------------------------------------

;//-----Promenljive koje koristimo u programu----------------------------------------------
.data
string byte "Welcome, this is the dancing square program.", 0dh, 0ah,
"To terminate this program press SPACE key or close the window.", 0dh, 0ah,
"You can choose your square color by typing one of the characters:", 0dh, 0ah,
"r- for red, b- for blue and g- for green.", 0dh, 0ah, 0	;//String koji opisuje funkciju programa
windowRect    SMALL_RECT <xmin, ymin, xmax, ymax>			;//Velicina prozora
wintitle byte "Dancing square", 0	;//Naslov programa
cursorInfo CONSOLE_CURSOR_INFO <>	;//Informacije o kursoru

.data?
buffer byte buffer_size dup(?)
stdInHandle handle ?
bytesRead dword ?
stdOutHandle handle ?

;//----------------Pocetak programa----------------------------------------------------------
.code
main proc

;//----Ispisivanje teksta na pocetku programa------------------------------------------------
loopstr:
	call Clrscr;	//Brisemo sve iz prozora (ukoliko je ovo druga iteracija)
	mov edx, offset string;	//Postavljamo pokazivac na pocetak stringa
	call WriteString;	//Ispisujemo string


	invoke getstdhandle, std_input_handle;	// Postavlja handle za upis
	mov stdInHandle, eax


	invoke ReadConsole, stdInHandle, ADDR buffer,
		buffer_size, ADDR bytesRead, 0	;// Cita podatak iz conzole, stavlja ga u bafer


	mov esi, offset buffer; //pokazivac na bafer
	mov ecx, bytesRead;		//broj procitanih bajtova
	mov ebx, type buffer;	//tip/velicina bafera

;//--Odredjivanje boje kvadrata--------------------------------------------------------------
	.if buffer == 'r'	;//Ispitujemo da li je u baferu vrednost 'r'
		mov ax, red + (white * 16)	;// AL koristimo za postavljanje boje kvadrate, AH za
	.elseif buffer == 'b'			;// postavljanje boje pozadine
		mov ax, blue + (white * 16)	;//
	.elseif buffer == 'g'
		mov ax, green + (white * 16)
	.endif

		jnz loopstr	;//Ukoliko je unet karakter koji ne pripada skupu {'r','b','g'} ponovo se
					;//vracamo na pocetak programa sve dok korisnik ne unese korektnu vrenost

	call SetTextColor ;//Postavljamo zeljenu boji kvadrata i pozadine
	call Clrscr	;//
;//------------------------------------------------------------------------------------------

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE;	//Postavlja handle za ispis podataka
	mov  stdOutHandle, eax

	INVOKE GetConsoleCursorInfo, stdOutHandle, ADDR cursorInfo;//Cita trenutno stanje kursora
	mov  cursorInfo.bVisible, 0 ;	// Postavlja vidljivost kursora na nevidljiv
	INVOKE SetConsoleCursorInfo, stdOutHandle, ADDR cursorInfo;//Postavlja novo stanje kursora

;//----Postavlja ime prozora-----------------------------------------------------------------
	INVOKE SetConsoleTitle, ADDR wintitle

;//----Pocetna pozicija kvadrata-------------------------------------------------------------
	mov dl, 20
	mov dh, 10
;//------------------------------------------------------------------------------------------
loop1:
	

	;// iscrtavanje kvadrata
	call gotoxy;		//Pomera kursor na pozicije zadate sa: x = dl, y = dh
	mov al, square;		//Upisuje vrednost simbola square (DBh=219dec) u al
	call writechar;		//Ispisuje simbol square(ASCII DBh) na poziciju kursora x,y
	inc dl;				//Povecava koordinatu x za 1
	call gotoxy;		//Pomera kursor na novu poziciju
	mov al, square;		//Upisuje vrednost simbola square (DBh=219dec) u al
	call writechar;		//Ispisuje simbol square(ASCII DBh) na poziciju kursora x+1,y
	;//---------------------------------------------------------------------------------------

	mov  eax, drawDelay;	//Upisuje duzinu pauze (u mili sekundama) u EAX
	call Delay;				//Pauzira trenutni proces u trajanju definisanom vrednoscu u EAX


	;//Brisanje kvadrata----------------------------------------------------------------------
	call gotoxy;		//Pomera kursor na poslednju poziciju iscrtavanja (x=dl,y=dh)
	mov al, ' ';		//U al upisuje vrednost simbola " " (ASCII 20h)
	call writechar;		//Ispisuje simbol " " na poziciju kursora x,y
	dec dl;				//Smanjuje vrednost koordinate x za 1
	call gotoxy;		//Pomera  kursor na poziciju x-1,y
	mov al, ' '
	call writechar

	;//Promena velicine prozora----------------------------------------------------------------
	INVOKE SetConsoleWindowInfo,
		stdOutHandle, TRUE, ADDR windowRect
	;//

	;//Prekidanje rada programa----------------------------------------------------------------
	INVOKE GetKeyState, VK_SPACE;	//Ukoliko je pritisnut taster SPACE, postavlja najvisi bit
	test eax, 80000000h;	// EAX registra na "1", test proverava da li je taj bit na jedinici
	.if !zero? ;			// i ako jeste skacemo na loopexit cime se rad programa zavrsava
		jmp loopexit
	.endif
	;//----------------------------------------------------------------------------------------

	;//Dodeljivanje nasumicnih koordinata------------------------------------------------------
	mov eax, xmax;		//Opseg nasumicnog dodeljivanja rand(0,xmax)
	call randomrange;	//Vraca nasumicnu vrednost iz dodeljenog opsega
	mov dl, al;			//Upisuje dobijenu vrednost u dl (x koordinata)
	mov eax, ymax;		//Opseg nasumicnog dodeljivanja rand(0,ymax)
	call randomrange;	//Vraca nasumicnu vrednost iz dodeljenog opsega
	mov dh, al;			//Upisuje dobijenu vrednost u dl (y koordinata)
	;//-----------------------------------------------------------------------------------------

	jmp loop1


loopexit:
	INVOKE ExitProcess,0

main ENDP
END main