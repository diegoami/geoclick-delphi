(******************************************************************)
(* Copyright 1997, Microchip Systems / Carl Bunton                *)
(* Email: Twojags@cris.com                                        *)
(* Web-page: http://www.concentric.net/~twojags                   *)
(*                                                                *)
(* This code is not for redistribution in whole or in part.  It   *)
(* may be used in compiled program format only.                   *)
(*                                                                *)
(* This program was written in Delphi 2 because version 2         *)
(* compiles a much smaller executable using the windows api.  It  *)
(* should be fully compatible with Delphi 3, but will produce a   *)
(* noticable increase of size in the final compiled program.      *)
(******************************************************************)

(******************)
(* INFLATE METHOD *)
(******************)
UNIT SFXinflt;

INTERFACE

USES  SFXgbls,SFXmisc, Windows;

{$DEFINE PKZIP_BUG_WORKAROUND}

CONST
    { Tables for deflate from PKZIP's appnote.txt. }
    cplens: ARRAY[0..30] OF WORD = { Copy lengths FOR literal codes 257..285 }
            (3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35,
             43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0);
            { note: see note #13 above about the 258 in this list. }
    cpdist: ARRAY[0..29] OF WORD = { Copy offsets FOR distance codes 0..29 }
            (1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257,
             385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289,
             16385, 24577);
    cplext: ARRAY[0..30] OF BYTE = { Extra bits FOR literal codes 257..285 }
            (0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4,
             4, 4, 5, 5, 5, 5, 0, 99, 99); { 99==invalid }
    cpdext: ARRAY[0..29] OF BYTE = { Extra bits FOR distance codes }
            (0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9,
             10, 10, 11, 11, 12, 12, 13, 13);

    { AND'ing with mask[n] masks the lower n bits }
    maskr: ARRAY[0..16] OF WORD =   ($0000, $0001, $0003, $0007, $000f,
            $001f, $003f, $007f, $00ff, $01ff, $03ff, $07ff, $0fff,
             $1fff, $3fff, $7fff, $ffff);

    lbits = 9;
    dbits = 6;
    N_MAX = 288;

TYPE
    PT = ^Thuft;
    Thuft = RECORD
       e ,
       b : shortint;
       n : WORD;
       next : PT;
    END;

    BufPtr             = ^BufType;
    BufType            =  ARRAY[0..WSIZE] OF BYTE;

VAR
    hufts             : WORD;
    bb                : LONGINT;   { bit buffer (Static)}
    bk                : WORD;      { bits in bit buffer (Static)}
    InBuf             : BufPtr;
    Slide             : BufPtr;
    InPTR             : WORD;      { Index FOR ZipFile input buffer }
    ZipCount          : DWORD;     { Count OF bytes in ZipFile input buffer }
    WP                : WORD;      { Static Global }
    fixed_tl,fixed_td : PT;        { Static Global }


PROCEDURE inflate;  {(StartPos: LONGINT);}

IMPLEMENTATION

(*--------------------------------------------------------------------------*)
FUNCTION GetNextByte: INTEGER;
VAR
    i: INTEGER;
BEGIN
    {EndFile := false;}
  IF InPTR >= ZipCount THEN
  BEGIN
    ReadFile(InFile, InBuf^, Min(Bytes_To_Go, WSIZE), ZipCount, NIL);

     IF (Header.BitFlag AND 1) = 1 THEN
     BEGIN
        FOR i := 0 TO ZipCount - 1 DO
        BEGIN
                InBuf[i] := InBuf[i] XOR decrypt_byte;
           UDK(BYTE(InBuf[i]));
        END;
     END;
     InPtr := 0;
  END;

  IF ZipCount = 0 THEN
  BEGIN
    {EndFile := TRUE;}
     Bytes_To_Go :=0;
     InPtr := 0;
     GetNextByte := -1;
  END ELSE BEGIN
    GetNextByte := InBuf^[InPTR];
     Inc(InPTR);
  END;
END;

(*--------------------------------------------------------------------------*)
FUNCTION Get_Compressed : INTEGER;
BEGIN
  (* Unshrink & UnReduce & Explode & Inflate *)

  IF Bytes_To_Go <= 0 THEN
    result := -1
  ELSE BEGIN
    result := GetNextByte;
     Dec(Bytes_To_Go);
  END;
END;

(*--------------------------------------------------------------------------*)
PROCEDURE NEEDBITS (n:WORD; VAR b:LONGINT; VAR k:WORD);
VAR
    c: INTEGER;
BEGIN
   WHILE(k < n)  DO
   BEGIN
      c := Get_Compressed;
      b := b or LONGINT(c) SHL k;   { no parens!! }
      inc(k, 8);
   END;
END;

(*--------------------------------------------------------------------------*)
PROCEDURE DUMPBITS (n:WORD; VAR b:LONGINT; VAR k:WORD);
BEGIN
    b := b SHR n;
  k := k - n;
END;

(*--------------------------------------------------------------------------*)
{ "decompress" an inflated type 0 (stored) block. }
PROCEDURE inflate_stored;
VAR
    n: WORD;                    { number OF bytes in block }
  w: WORD;                { current window position }
  b: LONGINT;             { bit buffer }
  k: WORD;                { number OF bits in bit buffer }
  BytesWritten: DWORD;
BEGIN

  { make local copies OF globals }
  b := bb;                  { initialize bit buffer }
  k := bk;
  w := wp;                  { initialize window position }

  { go TO BYTE boundary }
  n := k AND 7;
  DUMPBITS(n, b, k);

  { get the length AND its complement }
  NEEDBITS(16, b, k);
  n := (WORD(b) AND $ffff);
  DUMPBITS(16, b, k);
  NEEDBITS(16, b, k);

  IF (n <> (not WORD(b)) AND $ffff) THEN
  BEGIN
    wp :=0;

     (* ***********  REM'D RAISE  ************* *)
//      raise E_RAISE.Create(LoadStr(E_BADBLOCK));
  END;

  DUMPBITS(16, b, k);

  { read AND output the compressed data }
  WHILE (n <> 0) DO
  BEGIN
        dec(n);
        NEEDBITS(8, b, k);
        slide^[w] := WORD(b);
        inc(w);

        IF (w = WORD(WSIZE)) THEN
        BEGIN
        WriteFile(OutFile, Slide^, w, BytesWritten, NIL);

            crc32_buf(pChar(Slide), w, Crc32Val);
        w := 0;
     END;
     DUMPBITS(8, b, k);
  END;

  { restore the globals from the locals }
  wp := w;                      { restore global window pointer }
  bb := b;                      { restore global bit buffer }
  bk := k;
END;

(*--------------------------------------------------------------------------*)
FUNCTION huft_free(t: PT): INTEGER;
    { Free the malloc'ed tables built by huft_build(), which makes a linked
   list OF the tables it made, with the links in a dummy first entry OF
   each table. }
VAR
    p,q: PT;
BEGIN
  { Go through linked list, freeing from the malloced (t[-1]) address. }
  p :=t;
  {p :=t.next;}
  WHILE (p <> NIL) DO
  BEGIN
        dec(p);
    q := p^.Next;
        freemem(p);
     p :=q;
  END;
  result := 0;
END;

(*--------------------------------------------------------------------------*)
FUNCTION huft_build(VAR b: ARRAY OF WORD; n,s: WORD; VAR d: ARRAY OF WORD; VAR e: ARRAY OF BYTE;
    VAR t,HF: PT; VAR m: INTEGER): INTEGER;
CONST
  BMAX = 16;
VAR
    a: WORD;
  c: ARRAY[0..BMAX] OF WORD;        { bit length count table }
  el: WORD;
  f: WORD;
  g: INTEGER;                           { maximum code length }
  h: INTEGER;                   { table level }
  i: WORD;                      { counter, current code / counter }
  j: WORD;                      { counter }
    k: INTEGER;                     { number OF bits in current code }
  lx: ARRAY[-1..BMAX+1] OF INTEGER;
  p: ^WORD;
  q: PT;
  r: Thuft;
  u: ARRAY[0..BMAX] OF PT;
  v: ARRAY[0..N_MAX] OF WORD;   { values in order OF bit length }
  w: WORD;
  x: ARRAY[0..BMAX+1] OF WORD;  { bit offsets, THEN code stack }
  xp: ^WORD;
  y: INTEGER;
  z: WORD;
BEGIN

  { Generate counts FOR each bit length }
  IF n > 256 THEN               { set length OF EOB code, IF any }
    el := b[256]
  ELSE
    el := BMAX;

  fillchar(c[0],sizeof(c),0);

  p := @b;
  i := n;

    REPEAT
    inc(c[p^]);          { assume all entries <= BMAX }
     inc(p);
     dec(i);
  UNTIL (i = 0);

  { null input--all zero length codes }
    IF c[0] = n THEN
  BEGIN
    t := NIL;
     m := 0;
     result :=0;
     exit;
  END;

  { Find minimum AND maximum length, bound *m by those }
  FOR j := 1 TO BMAX DO
    IF c[j] <> 0 THEN
        break;

  k := j;                       { minimum code length }

  IF (WORD(m) < j) THEN
    {m := INTEGER(j);}
    m := j;

  FOR i := BMAX DOWNTO 1 DO
    IF c[i] <> 0 THEN
        break;

    g := i;                       { maximum code length }

    IF WORD(m) > i THEN
    m := INTEGER(i);

  { Adjust last length count TO fill out codes, IF needed }
  y := 1 SHL j;
  FOR j := j TO i - 1 DO
  BEGIN
    y := y - c[j];
     IF y < 0 THEN
     BEGIN
        result :=2;             { bad input: more codes than bits }
        exit;
     END;
     y := y SHL 1;
    END;

  y := y - c[i];
  IF y < 0 THEN
  BEGIN
    result := 2;
     exit;
  END;

  inc(c[i],y);

  { Generate starting offsets into the value table FOR each length }
  x[1] := 0;
  j := 0;

  p := @c[1];
  xp := @x[2];

  dec(i);               { note that i = g from above }
  WHILE (i > 0) DO
  BEGIN
    inc(j, p^);
     xp^ := j;
     inc(p);
    inc(xp);
     dec(i);
  END;

    { Make a table OF values in order OF bit lengths }
  p := @b;
  i := 0;
  REPEAT
    j := p^;
       IF (j <> 0) THEN
        BEGIN
        v[x[j]] := i;
        inc(x[j]);
        END;
        inc(p);
        inc(i);
  UNTIL i >= n;

  { Generate the Huffman codes AND FOR each, make the table entries }
  h          := -1;                  { no tables yet--level -1 }
  i          := 0;
  lx[-1] := 0;                   { ditto }
  p          := @v;                  { grab values in bit order }
  q          := NIL;                 { ditto }
    t        := NIL;
  u[0]   := NIL;                 { just TO keep compilers happy }
  w          := 0;                   { no bits decoded yet }
  x[0]   := 0;                   { first Huffman code is zero }
  z          := 0;                   { ditto }

  { go through the bit lengths (k already is bits in shortest code) }
  FOR k := k TO g DO
  BEGIN
    a := c[k];
        WHILE (a <> 0) DO
        BEGIN
        dec(a);

        { here i is the Huffman code OF length k bits FOR value *p }
        { make tables up TO required level }
        {WHILE k > INTEGER(w + lx[h]) DO}
        WHILE k > (w + lx[h]) DO
        BEGIN
            inc(w,lx[h]);        { add bits already decoded }
           inc(h);

            { compute minimum size table less than or equal TO *m bits }
           z := g - w;              { upper limit }
           {IF z > WORD(m)}
           IF z > m THEN
            {z :=WORD(m);}
            z := m;

           {j := WORD(k - w);}
           j := k - w;
           f := 1 SHL j;
           IF f > (a + 1) THEN  { TRY a k-w bit table }
           BEGIN                { too few codes FOR k-w bit table }
            dec(f,a+1);         { deduct codes from patterns left }
              xp := @c[k];
              inc(j);
              WHILE (j < z) DO  { TRY smaller tables up TO z bits }
                BEGIN
                inc(xp);
                f := f SHL 1;
                 IF f <= xp^ THEN
                    break;      { enough codes TO use up j bits }
                 f := f - xp^;  { ELSE deduct codes from patterns }
                 inc(j);
                END;
           END;

            IF ((w + j > el) AND (w < el)) THEN
            j := el - w;        { make EOB code END at table }

           z := 1 SHL j;        { table entries FOR j-bit table }
            lx[h] := j;         { set table size in stack }

            { allocate AND link in new table }
           GetMem(q, (z + 1) * sizeof(Thuft));
           IF q = NIL THEN
           BEGIN
            IF (h > 0) THEN
                huft_free(u[0]);
              result :=3;
              exit;
           END;

           inc(hufts,z+1);          { track memory usage }

                r.next :=HF;
           q^.next :=HF;
           inc(q);
           HF := q;
           u[h] := q;

           IF t = NIL THEN
            t := q;

           { connect TO last table, IF there is one }
           IF h > 0 THEN
            BEGIN
                x[h]:= i;               { save pattern FOR backing up }

                r.b := lx[h-1];     { bits TO dump before this table }
                r.e := (16 + j);    { bits in this table }
            r.next := q;        { pointer TO this table }
                j := (i AND ((1 SHL w) - 1)) SHR (w - lx[h-1]);

              { connect TO last table }
               {****************************************************************
               Use the following line in the debugger TO verify the allocated
                 memory boundries with data being inserted.

                 *->   (LONGINT(u[h-1])+(j*sizeof(Thuft))) - LONGINT(u[h-1])   <-*
               ****************************************************************}
              move(r,pointer(LONGINT(u[h-1]) + (j*sizeof(Thuft)))^,sizeof(r));
           END;
        END;

        { set up table entry in r }
        r.b := shortint(k - w);

            {IF (LONGINT(addr(p^)) >= LONGINT(addr(v[n])))}
            IF (LONGINT(p) >= LONGINT(@v[n])) THEN
            r.e := 99      { out OF values--invalid code }
        ELSE IF (p^ < s) THEN
        BEGIN
            IF p^ < 256 THEN        { 256 is END-OF-block code }
            r.e := 16
           ELSE
            r.e := 15;

           r.n := p^;               { simple code is just the value }
           inc(p);
        END ELSE BEGIN
            r.e := e[p^ - s];       { non-simple--look up in lists }
           r.n := d[p^ - s];
           inc(p);
        END;

        { fill code-like entries with r }
        f := 1 SHL (k - w);
        j := i SHR w;
        WHILE (j < z) DO
        BEGIN
            {****************************************************************
            Use the following line in the debugger TO verify the allocated
              memory boundries with data being inserted.

              *->   (LONGINT(q)+(j*sizeof(Thuft))) - LONGINT(q)    <-*
            ****************************************************************}
            move(r,pointer(LONGINT(q) + (j * sizeof(thuft)))^,sizeof(r));
           inc(j,f);
        END;

        { backwards increment the k-bit code i }
        j := 1 SHL (k-1);
        WHILE (i AND j) <> 0 DO         {added...   <> 0 }
        BEGIN
            i := i XOR j;       {bitwise exclusive or}
           j := j SHR 1;
        END;

        i := i XOR j;        {bitwise exclusive or}

        { backup over finished tables }
        WHILE ((i AND ((1 SHL w) - 1)) <> x[h]) DO
        BEGIN
            dec(h);
           dec(w,lx[h]);                    { don't need TO update q }
        END;
     END;
  END;

  { return actual size OF base table }
  m := INTEGER(lx[0]);

  IF (y <> 0) THEN
    y := 1
  ELSE
    y := 0;

  IF (g <> 1) THEN
    g := 1
  ELSE
    g := 0;
  result := (y AND g);

  { Return true (1) IF we were given an incomplete table }
  {result := (y <> 0) AND  (g <> 1);}
END;

(*--------------------------------------------------------------------------*)
FUNCTION inflate_codes(VAR tl,td: PT; bl, bd: INTEGER): INTEGER;
(* tl,td:   literal/length AND distance decoder tables  *)
(* bl,bd:   number OF bits decoded by tl[] AND td[]     *)

(* inflate (decompress) the codes in a deflated (compressed) block.
   Return an error code or zero IF it all goes ok. *)
VAR
  e: WORD;               { table entry flag/number OF extra bits }
  n,d: WORD;           { length AND index FOR copy }
  w: WORD;               { current window position }
  t: PT;  {Thuft}      { pointer TO table entry }
  ml,md: WORD;         { masks FOR bl AND bd bits }
  b: LONGINT;          { bit buffer }
  k: WORD;             { number OF bits in bit buffer }
  BytesWritten: DWORD;
BEGIN

    { make local copies OF globals }
  b := bb;             { initialize bit buffer }
  k := bk;
  w := wp;             { initialize window position }

  { inflate the coded data }
  ml := maskr[bl];     { precompute masks FOR speed }
  md := maskr[bd];
    REPEAT
    NEEDBITS(bl,b,k);
     t := pointer(LONGINT(tl) + ((WORD(b) AND ml) * sizeof(Thuft)));
     {t :=ptr(seg(tl^), ofs(tl^)+ ((WORD(b) AND ml) * sizeof(Thuft)));}

     (* Inflate_Fixed & Inflate_Dynamic *)
     {with CentralZipHeader DO
        IF CalcProgress(False, PMode, Percent, UnpackedSize - Bytes_To_Go, UnpackedSize) THEN
           DoProgress(Percent);}

     e := t^.e;
     IF (e > 16) THEN
        WHILE (e > 16) DO
        BEGIN
            IF (e = 99) THEN
           BEGIN
                result :=1;
              exit;
           END;
           DUMPBITS(t^.b,b,k);
           dec(e,16);
                NEEDBITS(e,b,k);

                t := pointer(LONGINT(t^.next) + ((b AND maskr[e]) * sizeof(Thuft)));
                e := t^.e;
        END;

     DUMPBITS(t^.b,b,k);
     IF (e = 16) THEN           { THEN it's a literal }
     BEGIN
        slide^[w] := t^.n;
        inc(w);
        //Dec(Bytes_To_Go);

        IF (w = WORD(WSIZE)) THEN
        BEGIN
                //Inc(ExtCount);
            WriteFile(OutFile, Slide^, w, BytesWritten, NIL);

                crc32_buf(pChar(Slide), w, Crc32Val);
           w := 0;
        END;
     END ELSE BEGIN              { it's an EOB or a length }
        { exit IF END OF block }
        IF (e = 15) THEN
           break;

        { get length OF block TO copy }
        NEEDBITS(e,b,k);
        n := t^.n + (WORD(b) AND maskr[e]);
        {n := t^.n + (b AND maskr[e]);}
        DUMPBITS(e,b,k);

        { decode distance OF block TO copy }
        NEEDBITS(WORD(bd),b,k);
        {NEEDBITS(bd,b,k);}

        t := pointer(LONGINT(td) + ((b AND md) * sizeof(Thuft)));

        e := t^.e;
        IF e > 16 THEN
        REPEAT
           IF (e = 99) THEN
           BEGIN
              result :=1;
              exit;
           END;
           DUMPBITS(t^.b,b,k);
           dec(e,16);
           NEEDBITS(e,b,k);
           t := pointer(LONGINT(t^.next) + ((WORD(b) AND maskr[e]) * sizeof(Thuft)));
           {t := pointer(LONGINT(t^.next) + ((b AND maskr[e]) * sizeof(Thuft)));}
           e := t^.e;
        UNTIL (e <= 16);

        DUMPBITS(t^.b,b,k);
        NEEDBITS(e,b,k);

        d := WORD(w - t^.n - (b AND maskr[e]));

        DUMPBITS(e,b,k);

        { DO the copy }
        REPEAT
           d := (d AND (WSIZE-1));

           IF (d > w) THEN
            e := WSIZE - d
           ELSE
            e := WSIZE - w;

           IF (e > n) THEN
            e := n;

           dec(n, e);

           (* incrementing w by e bytes below... DO same with bytes_to_go
              prior TO value e changing *)
            //Dec(Bytes_To_Go, e);

           IF ((w - d) >= e) THEN  { this test assumes unsigned comparison }
           BEGIN
            move(slide^[d],slide^[w],e);
                inc(w,e);
                inc(d,e);
           END ELSE BEGIN              { DO it slow TO avoid memcpy() overlap }
            REPEAT
                slide^[w] := slide^[d];
                inc(w);
                inc(d);
                dec(e);
            UNTIL (e <= 0);
           END;

           IF (w = WORD(WSIZE)) THEN
           BEGIN
                WriteFile(OutFile, Slide^, w, BytesWritten, NIL);

                    crc32_buf(pChar(Slide), w, Crc32Val);
              w := 0;
           END;
        UNTIL n = 0;
     END;

  UNTIL (1 <> 1);

  { restore the globals from the locals }
  wp := w;                          { restore global window pointer   }
  bb := b;                              { restore global bit buffer       }
  bk := k;

  result :=0;
END;

(*--------------------------------------------------------------------------*)
PROCEDURE inflate_fixed;
{ decompress an inflated type 1 (fixed Huffman codes) block.  We should
  either replace this with a custom decoder, or at least precompute the
  Huffman tables. }
VAR
    i: INTEGER;                 { temporary variable }
  l: ARRAY[0..287] OF WORD;   { length list FOR huft_build }
  fixed_bl, fixed_bd: INTEGER;
  HFTD,HFTL: PT;
BEGIN

  { IF first time, set up tables FOR fixed blocks }
  IF (fixed_tl = NIL) THEN
  BEGIN
    { literal table }
    FOR i := 0 TO 287 DO
     BEGIN
        CASE i OF
              0..143: l[i] := 8;
           144..255: l[i] := 9;
           256..279: l[i] := 7;
           280..287: l[i] := 8;     { make a complete, but wrong code set }
        END;
     END;

        fixed_bl := 7;
        i := huft_build(l, 288, 257, cplens, cplext, fixed_tl, HFTL, fixed_bl);
        IF (i <> 0) THEN
        BEGIN
           fixed_tl := NIL;

        (* ********** REM'D RAISE ************ *)
//          raise E_RAISE.Create(LoadStr(E_CODESET));
        END;

        { distance table }
        FOR i := 0 TO 29 DO   { make an incomplete code set }
           l[i] := 5;

        fixed_bd := 5;

        i := huft_build(l, 30, 0, cpdist, cpdext, fixed_td, HFTD, fixed_bd);
        IF (i > 1) THEN
        BEGIN
        {ErrCode := IncompleteCodeSet;}
           huft_free(HFTL);
           fixed_tl := NIL;


        (* ********** REM'D RAISE ************ *)
        //raise E_RAISE.Create(LoadStr(E_CODESET));
        END;
  END;

  { decompress UNTIL an END-OF-block code }
  i := inflate_codes(fixed_tl, fixed_td, fixed_bl, fixed_bd);

  IF i <> 0 THEN

    (* ********** REM'D RAISE ************ *)
     //raise E_RAISE.Create(LoadStr(E_BADBLOCK));
     ;

END;

(*--------------------------------------------------------------------------*)
PROCEDURE inflate_dynamic;
VAR
    i: INTEGER;             { temporary variables }
  j: WORD;              {}
  l: WORD;              { last length }
  m: WORD;              { mask FOR bit lengths table }
  n: WORD;              { number OF lengths TO get }
  tl: PT;                   { literal/length code table }
  td: PT;               { distance code table }
  HFTL,HFTD: PT;
  bl: INTEGER;          { lookup bits FOR tl }
  bd: INTEGER;          { lookup bits FOR td }
  nb: WORD;             { number OF bit length codes }
  nl: WORD;             { number OF literal/length codes }
  nd: WORD;             { number OF distance codes }
  {$IFDEF PKZIP_BUG_WORKAROUND}
  ll: ARRAY[0..288+32] OF WORD;
  {$ELSE}
  ll: ARRAY[0..286+30] OF WORD;
  {$ENDIF}
  b: LONGINT;               { bit buffer }
  k: WORD;              { number OF bits in bit buffer }
CONST
    border: ARRAY[0..18] OF BYTE = { Order OF the bit length code lengths }
        (16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15);
  dummy1:  ARRAY[0..30] OF WORD =
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  dummy2:  ARRAY[0..30] OF BYTE = { Extra bits FOR literal codes 257..285 }
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); { 99==invalid }
BEGIN
    { make local bit buffer }
  b := bb;
  k := bk;

  { read in table lengths }
  NEEDBITS(5,b,k);
  nl := 257 + (WORD(b) AND $1f);    { number OF literal/length codes }
  DUMPBITS(5,b,k);
  NEEDBITS(5,b,k);
  nd := 1 + (WORD(b) AND $1f);      { number OF distance codes }
  DUMPBITS(5,b,k);
  NEEDBITS(4,b,k);
  nb := 4 + (WORD(b) AND $f);       { number OF bit length codes }
  DUMPBITS(4,b,k);
  {$IFDEF PKZIP_BUG_WORKAROUND}
  IF ((nl > 288) or (nd > 32)) THEN
  {$ELSE}
  IF ((nl > 286) or (nd > 30)) THEN
  {$ENDIF}

     (* ***********  REM'D RAISE  ************* *)
     //raise E_RAISE.Create(LoadStr(E_INVALIDLEN));
     ;

  { read in bit-length-code lengths }
  FOR j := 0 TO nb-1 DO
  BEGIN
    NEEDBITS(3,b,k);
     ll[border[j]] := WORD(b) AND 7;
     DUMPBITS(3,b,k);
  END;

  FOR j := nb TO 18 DO
    ll[border[j]] := 0;

  { build decoding table FOR trees--single level, 7 bit lookup }
  bl := 7;
    HFTL :=NIL;
  i := huft_build(ll, 19, 19, dummy1, dummy2, tl, HFTL, bl);
  IF (i <> 0) THEN
  BEGIN
    IF (i = 1) THEN
     {huft_free(tl);}
        huft_free(HFTL);



     (* ***********  REM'D RAISE  ************* *)
     //raise E_RAISE.Create(LoadStr(E_CODESET));

  END;

  { read in literal AND distance code lengths }
  n := nl + nd;
  m := maskr[bl];
  i := 0;
  l := 0;
  WHILE (WORD(i) < n) DO
  BEGIN
    NEEDBITS(WORD(bl),b,k);

     td := pointer(LONGINT(tl) + ((b AND m) * sizeof(Thuft)));

     j := td^.b;
     DUMPBITS(j,b,k);

     j := td^.n;
     IF (j < 16) THEN           { length OF code in bits (0..15) }
     BEGIN
        ll[i] := j;
        l := j;                 {* save last length in l }
        inc(i);
     END ELSE IF (j = 16) THEN {  REPEAT last length 3 TO 6 times }
     BEGIN
        NEEDBITS(2,b,k);
        j := 3 + (WORD(b) AND 3);
        DUMPBITS(2,b,k);
        IF (WORD(i) + j > n) THEN

            (* ***********  REM'D RAISE  ************* *)
            //raise E_RAISE.Create(LoadStr(E_CODESET));
           ;

        WHILE (j <> 0) DO
        BEGIN
            ll[i] := l;
           inc(i);
           dec(j);
        END
     END ELSE IF (j = 17) THEN      { 3 TO 10 zero length codes }
     BEGIN
        NEEDBITS(3,b,k);
        j := 3 + (WORD(b) AND 7);
        DUMPBITS(3,b,k);
        IF (WORD(i) + j > n) THEN

            (* ***********  REM'D RAISE  ************* *)
            //raise E_RAISE.Create(LoadStr(E_CODESET));
           ;

        WHILE (j <> 0) DO
        BEGIN
            ll[i] := 0;
           inc(i);
           dec(j);
        END;
        l := 0;
     END ELSE BEGIN             { j == 18: 11 TO 138 zero length codes }
        NEEDBITS(7,b,k);
        j := 11 + (WORD(b) AND $7f);
        DUMPBITS(7,b,k);
        IF (WORD(i) + j > n) THEN

               (* ***********  REM'D RAISE  ************* *)
            //raise E_RAISE.Create(LoadStr(E_CODESET));
           ;

        WHILE (j <> 0) DO
        BEGIN
            ll[i] := 0;
           inc(i);
           dec(j);
        END;
        l := 0;
     END;
  END;

  { free decoding table FOR trees }
  {huft_free(tl);}
  huft_free(HFTL);

  { restore the global bit buffer }
  bb := b;
  bk := k;

  { build the decoding tables for literal/length AND distance codes }
  bl := lbits;
  HFTL :=NIL;
  i := huft_build(ll, nl, 257, cplens, cplext, tl, HFTL, bl);
  IF (i <> 0) THEN
  BEGIN
     IF i = 1 THEN
        huft_free(HFTL);

        (* ***********  REM'D RAISE  ************* *)
     //raise E_RAISE.Create(LoadStr(E_CODESET));

  END;

  bd := dbits;
  HFTD :=NIL;
  i := huft_build(ll[nl], nd, 0, cpdist, cpdext, td, HFTD, bd);
  IF (i <> 0) THEN
  BEGIN
     IF i = 1 THEN
     BEGIN

        (* ***********  REM'D RAISE  ************* *)
        //raise E_RAISE.Create(LoadStr(E_CODESET));


{$ifdef PKZIP_BUG_WORKAROUND}
            {i := 0;   ********************** return as result??????}
        END;
{$ELSE}
            huft_free(HFTD);


            (* ***********  REM'D RAISE  ************* *)
        //raise E_RAISE.Create(E_CODESET);

        END;
    {huft_free(tl);}
    huft_free(HFTL);
    {result := i;}                { incomplete code set }
    result := IncompleteCodeSet;
    exit;
{$endif}
    END;

  { decompress UNTIL an END-OF-block code }
  IF (inflate_codes(tl, td, bl, bd)) <> 0 THEN
     // raise E_RAISE.Create(LoadStr(E_CODESET));
     ;

  { free the decoding tables, return }
  huft_free(HFTL);        {******** IF inflate_codes fails above, }
  huft_free(HFTD);        {******** memory is not released!!!    }

  { result :=0; }
  { result := None; }       { 100% correct result????}
END;

(*--------------------------------------------------------------------------*)
{ decompress an inflated block }
PROCEDURE inflate_block(VAR e: INTEGER);    { e = last block flag }
VAR
    t: WORD;             { block type }
  k: WORD;             { number OF bits in bit buffer }
  b: LONGINT;          { bit buffer }
BEGIN
    { make local bit buffer }
  b := bb;
  k := bk;

  { read in last block bit }
  NEEDBITS(1, b, k);
  e := INTEGER(b) AND 1;
  DUMPBITS(1, b, k);

  { read in block type */}
  NEEDBITS(2, b, k);
  t := WORD(b) AND 3;
  DUMPBITS(2, b, k);

  { restore the global bit buffer }
  bb := b;
  bk := k;

  { inflate that block type }
    CASE t OF
    0:  inflate_stored;
    1:  inflate_fixed;
    2: inflate_dynamic;
    ELSE
        (* ***********  REM'D RAISE  ************* *)
        //raise E_RAISE.Create(LoadStr(E_BADBLOCK));
        ;
    END;
END;

(*--------------------------------------------------------------------------*)
{ decompress an inflated entry }
PROCEDURE inflate;  {(StartPos: LONGINT);}
VAR
    e: INTEGER;          { last block flag }
    h: WORD;             { maximum struct huft's malloc'ed }
    BytesWritten: DWORD;
BEGIN
    //FSeek(StartPos, FILE_BEGIN);
    //Bytes_To_Go := LocalZipHeader.PackedSize;
    //Crc32Val    := CRC_MASK;

    InPTR := 0;
    ZipCount := 0;

  { initialize window, bit buffer }
  wp := 0;
  bk := 0;
  bb := 0;

  { decompress UNTIL the last block }
  h := 0;

  InBuf := NIL;  Slide := NIL;
  GetMem(InBuf, sizeof(InBuf^) + 1);
  GetMem(Slide, sizeof(Slide^) + 1);

  TRY
     fixed_tl :=NIL;
     fixed_td :=NIL;
     TRY
        REPEAT
           hufts := 0;
           inflate_block(e);
           IF (hufts > h) THEN
              h := hufts;
        UNTIL (e <> 0);

        // with LocalZipHeader DO
        //   IF CalcProgress(False, PMode, Percent, PackedSize - Bytes_To_Go, PackedSize) THEN
        //      DoProgress(Percent);

        IF wp > 0 THEN
        BEGIN
            WriteFile(OutFile, Slide^, wp, BytesWritten, NIL);


           crc32_buf(pChar(Slide), wp, Crc32Val);
           wp := 0;
        END;
     EXCEPT
        //MessageBox(0, 'Error...', 'Error', mb_OK)
     END;

  FINALLY
    dispose(InBuf);
    dispose(Slide);
  END;

END;
(*--------------------------------------------------------------------------*)

END.
