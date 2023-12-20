; Program linie.asm
; Wyświetlanie znaków * w takt przerwań zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zakończenie programu po naciśnięciu dowolnego klawisza
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16
 ASSUME cs:rozkazy
linia PROC
; przechowanie rejestrów
 push ax
 push bx
 push es
 mov ax, 0A000H ; adres pamięci ekranu dla trybu 13H
 mov es, ax
 mov bx, cs:adres_piksela ; adres bieżący piksela
 mov al, cs:kolor
 mov es:[bx], al ; wpisanie kodu koloru do pamięci ekranu
; przejście do następnego wiersza na ekranie

 cmp cs:koniec, 0
 jne druga_przek

; pierwsza przek.
 mov dx, 0
 mov ax, cs:przesuniecie
 div cs:sto
 mov cx, ax
 add cs:przesuniecie, 62
 mov ax, cs:przesuniecie
 mov dx, 0
 div cs:sto
 cmp cx, ax
 je jeden
 add bx, 320
 jeden:
 add bx, 1
 jmp sprawdz
 
 druga_przek:
 mov dx, 0
 mov ax, cs:przesuniecie
 div cs:sto
 mov cx, ax
 add cs:przesuniecie, 62
 mov ax, cs:przesuniecie
 mov dx, 0
 div cs:sto
 cmp cx, ax
 je jeden2
 add bx, 320
 jeden2:
 sub bx, 1
 jmp sprawdz
 
 sprawdz:
 ; sprawdzenie czy cała linia wykreślona
 cmp bx, 320*200
 jb dalej
 inc cs:koniec
 mov cs:przesuniecie, 0
 mov bx, 1
; zapisanie adresu bieżącego piksela
dalej:
 mov cs:adres_piksela, bx 
; odtworzenie rejestrów
 pop es
 pop bx
 pop ax
; skok do oryginalnego podprogramu obsługi przerwania
; zegarowego
 jmp dword PTR cs:wektor8
; zmienne procedury
kolor db 1 ; bieżący numer koloru
adres_piksela dw 1 ; bieżący adres piksela
sto dw 100
przesuniecie dw 0
wektor8 dd ?
koniec db 0
linia ENDP
; INT 10H, funkcja nr 0 ustawia tryb sterownika graficznego


zacznij:
 mov ah, 0
 mov al, 13H ; nr trybu
 int 10H
 mov bx, 0
 mov es, bx ; zerowanie rejestru ES
 mov eax, es:[32] ; odczytanie wektora nr 8
 mov cs:wektor8, eax; zapamiętanie wektora nr 8
; adres procedury 'linia' w postaci segment:offset
 mov ax, SEG linia
 mov bx, OFFSET linia
 cli ; zablokowanie przerwań
; zapisanie adresu procedury 'linia' do wektora nr 8
 mov es:[32], bx
 mov es:[32+2], ax
 sti ; odblokowanie przerwań
czekaj:
 cmp cs:koniec, 2
 je ku_koncowi
 mov ah, 1 ; sprawdzenie czy jest jakiś znak
 int 16h ; w buforze klawiatury
 jz czekaj
 ku_koncowi:
 mov ah, 0 ; funkcja nr 0 ustawia tryb sterownika
 mov al, 3H ; nr trybu
 int 10H
; odtworzenie oryginalnej zawartości wektora nr 8 
 mov eax, cs:wektor8
 mov es:[32], eax
; zakończenie wykonywania programu
 mov ax, 4C00H
 int 21H
rozkazy ENDS
stosik SEGMENT stack
 db 256 dup (?)
stosik ENDS
END zacznij 
