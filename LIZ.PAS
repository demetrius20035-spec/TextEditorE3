Program Compiler;

Uses Crt,Dos;

Const TypesVar:array[1..4]of record
        NameType:String[7];                   {Имя типа}
        SizeType:byte;                        {Размер типа}
        end=((NameType:'ЧИСЛО';  SizeType:2),
             (NameType:'СЛОВО';  SizeType:2),
             (NameType:'БАЙТ';   SizeType:1),
             (NameType:'СИМВОЛ'; SizeType:1));
      Word_Analize:array [1..9] of string[16]=
        ('ПОКА','ДЛЯ','ЕСЛИ','НАЧАЛО','КОНЕЦ','ПЕЧАТЬ','ЧТЕНИЕ','ОПРЕДЕЛИТЬ','НОВАЯСТРОКА');
      Digits:set of char=['0'..'9']; {Цифры}
      Bukvi:set of char=['А'..'Я','A'..'Z']; {Буквы}
      Symbol:set of char=['+','-','*','/',':','.',';','=','[',']','(',')','<','>','"','!','|',',',' ',#10,#13];

Type Metki=Record
       Position:word;           {Позиция подстановки}
       PosPerexod:word;         {Позиция перехода}
       TypeJmp:Byte;            {Тип перехода}
       End;
     VarMem=Record
       NameVar:string[20];      {Имя переменной}
       SizeVar:Word;            {Размер переменной}
       SizeType:Word;           {Размер типа переменной}
       TypeVar:string[7];       {Тип переменной}
       LabelPoint:Word;         {Указатель в буфере данных}
       End;

Var i,j,k:Integer;
    proverka:Boolean; {Флаги проверок}

    InStr:array[0..5000] of char;       {Считанная программа}
    OutStr:array[0..6000] of byte;      {Выходной COM файл}
    Data:Array [0..3000] of Byte;       {Данные программы}
    Code:Array [0..3000] of Byte;       {Буфер кода}
    LabelPoint:array[0..500] of Metki;  {Массив переходов}
    Variable:Array [1..200] of VarMem; {Таблица переменных}

    PositionOutFile:word;  {Позиция записи в файл}
    PositionInFile:word;   {Позиция чтения программы}
    PositionData:word;     {Позиция в данных}
    PositionCode:word;     {Позиция в коде}
    PositionVarPoint:word; {Позиция переходов}
    NewVarPoint:word;      {Позиция в массиве переменных}

    Linenews:word; {Указатель на перевод курсора}
    Charnews:Word; {Указатель на печатаемый символ}
    WrtNum:word;   {Указатель на процедуру печати числа}
    ReadNum:word;  {Указатель на процедуру перевода строки в число}
    BuffNum:word;  {Указатель на буффер печати числа}
    BuffRead:word; {Указатель на буфер чтения}

    DescriptFile:File;           {Дескриптор файла}
    LengthFile:word;             {Размер файла}
    FileInput,FileOutput:string; {Имя входного и выходного файла}

    StartProg:boolean;  {Признак начала программы}
    BeginOpred:Integer; {}
    BeginTemp:word;     {}

    Shift:word;    {Сдвиг в Com файле относительно начала сегмента}

    IdentTemp:string; {Вырезанное слово из прогрммы}

Procedure  ViragE;forward; {Глобальные процедура}
Procedure  ViragT;forward; {Глобальные процедура}
Procedure  ViragF;forward; {Глобальные процедура}

Function UpCase(c:char):char; {Функция перевода регистров}
  Begin
    if (c in ['a'..'z','а'..'п']) then c:=chr(ord(c)-32);
    if (c in ['р'..'я']) then c:=chr(ord(c)-80);
    UpCase:=c;
  End;

Function AnalWord:string; {Вырезает слово из программы}
  Var Temp_str:string;
  Begin
    Temp_str:=''; {Составляемая строка}
    proverka:=false;  {Проверка на строку}
    while InStr[PositionInFile] in Symbol+['{','}'] do {Пропускать управляющие символы}
      Begin
        if InStr[PositionInFile]='"' then Begin inc(PositionInFile); proverka:=not(proverka); Break; End;
        if InStr[PositionInFile]='{' then While InStr[PositionInFile]<>'}' do inc(PositionInFile);
        inc(PositionInFile);
      End;
    while (not(InStr[PositionInFile] in Symbol)) or proverka do
      Begin
        if proverka then
          Temp_str:=Temp_str+InStr[PositionInFile]
         else
          Temp_str:=Temp_str+UpCase(InStr[PositionInFile]);
        inc(PositionInFile);
        if InStr[PositionInFile]='"' then proverka:=not(proverka);
      End;
    while InStr[PositionInFile] in [' ',#10,#13,'{','}'] do {Пропускать управляющие символы}
      Begin
        if InStr[PositionInFile]='{' then While InStr[PositionInFile]<>'}' do inc(PositionInFile);
        inc(PositionInFile);
      End;
    AnalWord:=Temp_str; {Возвращает вырезанное слово}
  End;

Procedure MesageError(code:word; AnalizeStr:string);
  Begin
    Writeln('При компиляции возникла ошибка с кодом ',code,' .');
    case code of
      1 :Writeln('Открываюцая скобка не обнаружена');
      2 :Writeln('Ошибка в написании условия');
      3 :Writeln('Закрываюцая скобка не обнаружена');
      4 :Writeln('Не выделен блок программы (Начало .... Конец)');
      5 :Writeln('Переменная не была определена');
      6 :Writeln('Точка с запятой не обнаружена');
      7 :Writeln('Отсутствует оператор "ДЕЛАТЬ"');
      8 :Writeln('Неверное место определения оператора');
      9 :Writeln('Переменная должна быть типа "СЛОВО"');
     10 :Writeln('Цикл записан неправильно');
     11 :Writeln('Знак равенства не обнаружен');
     12 :Writeln('Отсутствует оператор "ТОГДА"');
     13 :Writeln('Многократное определение основного блока программы');
     14 :Writeln('Не найдено слово "НАЧАЛО"');
     15 :Writeln('Несовпадение количества "НАЧАЛО" и "КОНЕЦ"');
     16 :Writeln('Неправильно записан оператор "ПЕЧАТЬ"');
     17 :Writeln('Неправильно раставлены кавычки');
     18 :Writeln('Неправильная запись оператора "ЧТЕНИЕ"');
     19 :Writeln('Неправильное определение переменной');
     20 :Writeln('Неправильное определение массива');
     21 :Writeln('Неправильная запись массива');
     22 :Writeln('Несоответствие типа переменной');
     23 :Writeln('Повторное переопределение переменной');
     24 :Writeln('Неправильное место определения переменной');
     25 :Writeln('Ошибка в написании команды');
     26 :Writeln('Ошибка при анализе числа');
     27 :Writeln('Неправильная адресация переменной');
     28 :Writeln('Ошибка при считывание символа');
    End;
    if length(AnalizeStr)>=1 then Writeln('В строке - ',AnalizeStr);
    Halt(code);
  End;

Procedure WriteData1(Byte1:word);
  Begin
    Data[PositionData+0]:=Byte1;
    inc(PositionData,1);
  End;

Procedure WriteData2(Byte1,Byte2:word);
  Begin
    Data[PositionData+0]:=Byte1;
    Data[PositionData+1]:=Byte2;
    inc(PositionData,2);
  End;

Procedure WriteData3(Byte1,Byte2,Byte3:word);
  Begin
    Data[PositionData+0]:=Byte1;
    Data[PositionData+1]:=Byte2;
    Data[PositionData+2]:=Byte3;
    inc(PositionData,3);
  End;

Procedure WriteCode1(Byte1:word);
  Begin
    Code[PositionCode+0]:=Byte1;
    inc(PositionCode,1);
  End;

Procedure WriteCode2(Byte1,Byte2:word);
  Begin
    Code[PositionCode+0]:=Byte1;
    Code[PositionCode+1]:=Byte2;
    inc(PositionCode,2);
  End;

Procedure WriteCode3(Byte1,Byte2,Byte3:word);
  Begin
    Code[PositionCode+0]:=Byte1;
    Code[PositionCode+1]:=Byte2;
    Code[PositionCode+2]:=Byte3;
    inc(PositionCode,3);
  End;

Function EsliTerminal(stroka:string):word; {Проверка зарезервированных терминалов}
  Var Temp,i:word;
  Begin
    Temp:=0;
    for i:=1 to 9 do
      if Word_Analize[i]=stroka then Begin Temp:=i; Break; End;
    EsliTerminal:=Temp;
  End;

Function EsliPerem(stroka:string):word; {Проверка переменной}
  Var Temp,i:word;
  Begin
    Temp:=0;
    for i:=1 to 200 do
      if Variable[i].NameVar=stroka then Begin Temp:=i; Break; End;
    EsliPerem:=Temp;
  End;

Function EsliType(stroka:string):word; {Проверка типа переменной}
  Var Temp,i:word;
  Begin
    Temp:=0;
    for i:=1 to 4 do
      if TypesVar[i].NameType=stroka then Begin Temp:=i; Break; End;
    EsliType:=Temp;
  End;

Function StringError(sdf:string; Pos:Word):string; {Вырезание строки с ошибкой}
  Var Temp:string;
  Begin
    Temp:=sdf;
    while not(InStr[Pos] in [#10,#13]) do Begin Temp:=Temp+InStr[Pos]; inc(Pos); End;
    StringError:=Temp;
  End;

Procedure  ViragE;
  Var Symbol:char;
  Begin
    ViragT;
    Symbol:=' ';
    while not(InStr[PositionInFile] in [';',' ','|',')',']','=','"','<','>','!',',',':']) do
      Begin
        WriteCode1($50); {Push AX}
        if InStr[PositionInFile] in ['+','-'] then Symbol:=InStr[PositionInFile];
        inc(PositionInFile); ViragT;
        WriteCode1($5B); {Pop BX}
        WriteCode1($93); {Xchg AX,BX}
        Case Symbol of
          '+' : Begin
                  WriteCode2($03,$C3); {Add AX,BX}
                End;
          '-' : Begin
                  WriteCode2($2B,$C3); {Sub AX,BX}
                End;
        End;
      End;
  End;

Procedure  ViragT;
  Var Symbol:char;
  Begin
    ViragF;
    Symbol:=' ';
    while not(InStr[PositionInFile] in [';','+','-','|',')',']','=','"',' ','<','>','!',',',':']) do
      Begin
        WriteCode1($50); {Push AX}
        if InStr[PositionInFile] in ['*','/'] then Symbol:=InStr[PositionInFile];
        inc(PositionInFile); ViragF;
        WriteCode1($5B); {Pop BX}
        WriteCode1($93); {Xchg AX,BX}
        Case Symbol of
          '*' : Begin
                  WriteCode2($F7,$E3); {Mul BX}
                End;
          '/' : Begin
                  WriteCode3($33,$D2,$F7); WriteCode1($FB); {Idiv BX}
                End;
        End;
      End;
  End;

Procedure  ViragF;
  Var Code,dat:integer;
      tm:word;
      StrokaVremen:string[20];
  Begin
    if InStr[PositionInFile] in Digits then
      Begin
        StrokaVremen:=AnalWord;
        val(StrokaVremen,dat,Code);
        if Code<>0 then MesageError(26,'');
        WriteCode3($B8,Lo(dat),Hi(dat)); {mov AX,AnalWord}
      End;
    if UpCase(InStr[PositionInFile]) in Bukvi then
      Begin
        StrokaVremen:=AnalWord;
        tm:=EsliPerem(StrokaVremen);
        if tm>0 then
          Begin
            if Variable[tm].SizeType=Variable[tm].SizeVar then
              Begin
                WriteCode3($B8,Lo(Variable[tm].LabelPoint+shift),Hi(Variable[tm].LabelPoint+shift)); {mov AX,AnalWord}
                if (InStr[PositionInFile]<>'=') or ((InStr[PositionInFile]='=') and (InStr[PositionInFile+1]='=')) then
                  Begin
                    WriteCode1($93); {Xchg AX,BX}
                    if Variable[tm].SizeType=2 then
                      WriteCode2($8B,$07) {mov    AX,[BX]}
                     Else
                      Begin
                        WriteCode2($8A,$07); {mov    AL,[BX]}
                        WriteCode2($32,$E4); {xor    AH,AH}
                      End;
                  End;
              End
             Else
              Begin
                if InStr[PositionInFile]<>'[' then MesageError(27,'');
                WriteCode3($B8,Lo(Variable[tm].LabelPoint+shift),Hi(Variable[tm].LabelPoint+shift)); {mov AX,AnalWord}
              End;
          End
         Else
          MesageError(5,'');
      End;
    Case InStr[PositionInFile] of
      '"' : Begin
              WriteCode3($B8,Lo(ord(InStr[PositionInFile+1])),Hi(ord(InStr[PositionInFile+1])));
              inc(PositionInFile,2);
              if InStr[PositionInFile]<>'"' then
                MesageError(28,'')
               Else
                inc(PositionInFile);
            End;
      '[' : Begin
              inc(PositionInFile);
              WriteCode1($50); {Push AX}
              ViragE;
              inc(PositionInFile);
              if Variable[tm].SizeType=2 then WriteCode2($D1,$E0); {SHL AX,1}
              WriteCode2($8B,$D8);  {mov BX,AX}
              WriteCode1($58);      {Pop AX}
              WriteCode2($03,$D8);  {add BX,AX}
              WriteCode1($93);      {Xchg AX,BX}
              if (InStr[PositionInFile]<>'=') or ((InStr[PositionInFile]='=') and (InStr[PositionInFile+1]='=')) then
                Begin
                  WriteCode1($93);      {Xchg AX,BX}
                  if Variable[tm].SizeType=2 then
                    WriteCode2($8B,$07) {mov    AX,[BX]}
                   Else
                    Begin
                      WriteCode2($8A,$07); {mov    AL,[BX]}
                      WriteCode2($32,$E4); {xor    AH,AH}
                    End;
                End;
            End;
      '(' : Begin inc(PositionInFile); ViragE; inc(PositionInFile); End;
    End;
    If (InStr[PositionInFile]='=') and (InStr[PositionInFile+1]<>'=') Then
      Begin
        WriteCode1($50); {Push AX}
        inc(PositionInFile); ViragE;
        WriteCode1($5B); {Pop BX}
        if Variable[tm].SizeType=2 then
          WriteCode2($89,$07)  {mov [BX],AX}
         Else
          WriteCode2($88,$07);  {mov [BX],AL}
      End;
  End;

Procedure CodeProcedure; {Запись кода необходимых процедур}
  Begin
    WrtNum:=PositionData+1; {Код печати числа}
    WriteData1($51);
    WriteData2($B2,$24);
    WriteData2($88,$15);
    WriteData1($47);
    WriteData2($E2,$FB);
    WriteData1($59);
    WriteData2($33,$D2);
    WriteData1($4F);
    WriteData2($F7,$F3);
    WriteData3($80,$FA,$0A);
    WriteData2($73,$07);
    WriteData3($80,$C2,$30);
    WriteData2($88,$15);
    WriteData2($EB,$05);
    WriteData3($80,$C2,$37);
    WriteData2($88,$15);
    WriteData2($33,$D2);
    WriteData1($4F);
    WriteData2($E2,$E8);
    WriteData1($47);
    WriteData3($8A,$55,$01);
    WriteData3($80,$FA,$24);
    WriteData2($74,$0A);
    WriteData2($8A,$15);
    WriteData3($80,$FA,$30);
    WriteData2($75,$03);
    WriteData1($47);
    WriteData2($EB,$EE);
    WriteData2($8B,$D7);
    WriteData2($B4,$09);
    WriteData2($CD,$21);
    WriteData1($C3);

    BuffNum:=PositionData+Shift;
    for i:=1 to 17 do Begin Data[PositionData]:=ord('$'); inc(PositionData); End;

    Linenews:=PositionData+Shift;  {Строка перевода курсора}
    WriteData3(13,10,ord('$'));

    Charnews:=PositionData+Shift;  {Печать символа}
    WriteData2(32,ord('$'));

    ReadNum:=PositionData+1;   {Ввод числа или символа}
    WriteData2($33,$C0);
    WriteData2($8A,$15);
    WriteData3($80,$FA,$20);
    WriteData2($72,$18);
    WriteData3($80,$FA,$20);
    WriteData2($74,$10);
    WriteData3($80,$EA,$30);
    WriteData3($80,$FA,$09);
    WriteData2($77,$08);
    WriteData2($32,$F6);
    WriteData2($8B,$CA);
    WriteData2($F7,$E3);
    WriteData2($03,$C1);
    WriteData1($47);
    WriteData2($EB,$E1);
    WriteData1($C3);

    BuffRead:=PositionData+Shift;
    Data[PositionData]:=10; inc(PositionData);
    For i:=1 to 10 do Begin Data[PositionData]:=0; inc(PositionData); End;
  End;

Procedure WriteNumberCode(Znak:word); {Процедура печати содержимого AX}
  Begin
    WriteCode3($BB,Lo(10),Hi(10));
    WriteCode3($BF,Lo(BuffNum),Hi(BuffNum)); {адресс буфера}
    WriteCode3($B9,Lo(Znak),Hi(Znak));
    WriteCode3($E8,$00,$00);                 {Переход на печать}

    LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
    LabelPoint[PositionVarPoint].TypeJmp:=0;
    LabelPoint[PositionVarPoint].PosPerexod:=WrtNum; {Позиция перехода}
    inc(PositionVarPoint);
  End;

Procedure WriteStringCode(AnalWord:string); {Печать строки}
  Var Point:word;
  Begin
    AnalWord:=AnalWord+'$';
    Point:=PositionData+Shift;
    for i:=1 to length(AnalWord) do Begin Data[PositionData]:=ord(AnalWord[i]); inc(PositionData); End;
    WriteCode3($BA,Lo(Point),Hi(point));
    WriteCode2($B4,$09);
    WriteCode2($CD,$21);
  End;

Procedure ReadCode(Syst:word; symb:boolean);
  Begin
    WriteCode1($53);         {push  BX}
    WriteCode3($BF,Lo(BuffRead),Hi(BuffRead)); {mov   DI,offset fdf}
    if symb then
      WriteCode2($B4,$02)    {mov   AH,2}
     Else
      WriteCode2($B4,$06);   {mov   AH,7}
    WriteCode2($88,$25);     {mov   [DI],AH}
    WriteCode2($8B,$D7);     {mov   DX,DI}
    WriteCode2($B4,$0A);     {mov   AH,0Ah}
    WriteCode2($CD,$21);     {int   21h}
    WriteCode3($83,$C7,$02); {add   DI,2}
    if not(symb) then
      Begin
        WriteCode3($BB,Lo(Syst),Hi(Syst)); {mov  BX,10}
        WriteCode3($E8,$00,$00);           {call addr}

        LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
        LabelPoint[PositionVarPoint].TypeJmp:=0;
        LabelPoint[PositionVarPoint].PosPerexod:=ReadNum; {Позиция перехода}
        inc(PositionVarPoint);
      End
     Else
      Begin
        WriteCode2($8A,$05); {mov   AL,[DI]}
      End;
    WriteCode1($5B);         {pop   BX}
    if symb then
      WriteCode2($88,$07)    {mov   [BX],AL}
     Else
      WriteCode2($89,$07);    {mov   [BX],AX}
  End;

Procedure Compilator;
  Var StrokaVremen:string;
      pt,Perevod,Code,i,PosStr,ForVar:word;
      PVT1,PVT2,PVT3,PVT4,PVT5,PVT6:word;
      BeginEnd,Flag:boolean;
      symb,znak1,znak2:char;
  Begin
    if StartProg then BeginEnd:=True Else BeginEnd:=False;
    Flag:=true;
    while Flag do
      Begin
        IdentTemp:=AnalWord;
        PosStr:=PositionInFile;
        if EsliTerminal(IdentTemp)=1 then
          Begin {Пока}
            If StartProg and (BeginTemp>0) then
              Begin
                LabelPoint[PositionVarPoint].PosPerexod:=PositionCode-2; {Позиция перехода}
                LabelPoint[PositionVarPoint].TypeJmp:=1;
                PVT1:=PositionVarPoint; inc(PositionVarPoint);
                if InStr[PositionInFile]<>'(' then MesageError(1,StringError(IdentTemp,PosStr));
                inc(PositionInFile);
                ViragE;
                znak1:=InStr[PositionInFile];
                znak2:=InStr[PositionInFile+1];
                if not (znak1 in ['<','>','=']) then MesageError(2,StringError(IdentTemp,PosStr));
                WriteCode1($50); {Push AX}
                inc(PositionInFile);
                if znak2 in ['"','>','<','='] then inc(PositionInFile);
                ViragE;
                if InStr[PositionInFile]<>')' then MesageError(3,StringError(IdentTemp,PosStr));
                WriteCode1($5B); {Pop BX}
                WriteCode2($3B,$D8); {cmp AX,BX}
                case znak1 of
                  '<' : case znak2 of
                          '=' : WriteCode2($76,$03); {jbe ;<=}
                          '>' : WriteCode2($75,$0D); {jne ;<>}
                         else
                          WriteCode2($72,$03); {jb ;<}
                        end;
                  '>' : case znak2 of
                          '=' : WriteCode2($73,$03); {jae ssdf ;>=}
                         else
                          WriteCode2($77,$03); {ja ssdf ;>}
                        end;
                  '=' : if znak2='=' then WriteCode2($74,$03); {je ssdf ;=}
                end;
                WriteCode3($E9,$00,$00); {jmp addr }
                LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
                PVT2:=PositionVarPoint; inc(PositionVarPoint);
                StrokaVremen:=AnalWord;
                if StrokaVremen='ДЕЛАТЬ' then
                  Begin
                    pt:=PositionInFile; StrokaVremen:=AnalWord;
                    if StrokaVremen='НАЧАЛО' then
                      Begin
                        PositionInFile:=pt;
                        Compilator;
                      End
                     Else
                      MesageError(4,StringError(IdentTemp,PosStr));
                  End
                 Else
                  MesageError(7,StringError(IdentTemp,PosStr));

                WriteCode3($E9,$00,$00); {jmp addr }
                LabelPoint[PVT1].Position:=PositionCode-2; {Позиция подстановки}

                LabelPoint[PVT2].PosPerexod:=PositionCode-2; {Позиция перехода}
                LabelPoint[PVT2].TypeJmp:=1;

              End
             Else
              MesageError(8,StringError(IdentTemp,PosStr));
          End
         Else
          if EsliTerminal(IdentTemp)=2 then
            Begin {Для}
              If StartProg and (BeginTemp>0) then
                Begin
                  StrokaVremen:=AnalWord;
                  pt:=EsliPerem(StrokaVremen);
                  if Variable[pt].TypeVar<>'СЛОВО' then
                    MesageError(9,StringError(IdentTemp,PosStr));
                  if pt<>0 then
                    Begin
                      if (InStr[PositionInFile]='=') then
                        Begin
                          PositionInFile:=PositionInFile-length(StrokaVremen);
                          ViragE;
                          symb:=InStr[PositionInFile];
                          if (symb='<') or (symb='>') then
                            Begin
                              WriteCode1($53); {Push BX}
                              StrokaVremen:=AnalWord;
                              PositionInFile:=PositionInFile-length(StrokaVremen);
                              ViragE;
                              WriteCode1($5B); {pop     BX}
                              ForVar:=PositionData+Shift;
                              Data[PositionData]:=0; Data[PositionData+1]:=0;
                              inc(PositionData,2);
                              WriteCode3($BF,Lo(ForVar),Hi(ForVar)); {mov DI,addr}
                              WriteCode2($89,$05); {mov [DI],AX}

                              LabelPoint[PositionVarPoint].PosPerexod:=PositionCode-2; {Позиция перехода}
                              LabelPoint[PositionVarPoint].TypeJmp:=1;
                              PVT1:=PositionVarPoint;
                              inc(PositionVarPoint);
                              WriteCode1($53); {Push BX}
                              WriteCode3($BF,Lo(ForVar),Hi(ForVar)); {mov DI,addr}
                              WriteCode2($8B,$05); {mov AX,[DI]}
                              WriteCode2($39,$07); {cmp [BX],AX}
                              if (Symb='>') then WriteCode2($76,$03); {jbe +3}
                              if (Symb='<') then WriteCode2($73,$03); {jae ssdf}
                              WriteCode3($E9,$00,$00); {jmp addr }
                              LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
                              PVT2:=PositionVarPoint;
                              inc(PositionVarPoint);
                              StrokaVremen:=AnalWord;
                              if StrokaVremen='ДЕЛАТЬ' then
                                Begin
                                  pt:=PositionInFile; StrokaVremen:=AnalWord;
                                  if StrokaVremen='НАЧАЛО' then
                                    Begin
                                      PositionInFile:=pt;
                                      Compilator;
                                    End
                                   Else
                                    MesageError(4,StringError(IdentTemp,PosStr));
                                End
                               Else
                                MesageError(10,StringError(IdentTemp,PosStr));
                              WriteCode1($5B); {pop     BX}
                              if (Symb='>') then WriteCode2($FF,$07); {inc word ptr [BX]}
                              if (Symb='<') then WriteCode2($FF,$0F); {dec word ptr [BX]}
                              WriteCode3($E9,$00,$00); {jmp addr }
                              LabelPoint[PVT1].Position:=PositionCode-2; {Позиция подстановки}
                              LabelPoint[PVT2].PosPerexod:=PositionCode-2; {Позиция перехода}
                              LabelPoint[PVT2].TypeJmp:=1;
                            End
                           Else
                            MesageError(10,StringError(IdentTemp,PosStr));
                        End
                       Else
                        MesageError(11,StringError(IdentTemp,PosStr));
                    End
                   Else
                    MesageError(5,StringError(IdentTemp,PosStr));
                End
               Else
                MesageError(8,StringError(IdentTemp,PosStr));
            End
           Else
            if EsliTerminal(IdentTemp)=3 then
              Begin {Если}
                If StartProg and (BeginTemp>0) then
                  Begin
                    if InStr[PositionInFile]<>'(' then MesageError(1,StringError(IdentTemp,PosStr));
                    inc(PositionInFile);
                    ViragE;
                    znak1:=InStr[PositionInFile];
                    znak2:=InStr[PositionInFile+1];
                    if not (znak1 in ['<','>','=']) then MesageError(2,StringError(IdentTemp,PosStr));
                    WriteCode1($50); {Push AX}
                    inc(PositionInFile);
                    if znak2 in ['"','>','<','='] then inc(PositionInFile);
                    ViragE;
                    if InStr[PositionInFile]<>')' then MesageError(3,StringError(IdentTemp,PosStr));
                    WriteCode1($5B); {Pop BX}
                    WriteCode2($3B,$D8); {cmp AX,BX}
                    case znak1 of
                      '<' : case znak2 of
                              '=' : WriteCode2($76,$03); {jbe ssdf ;<=}
                              '>' : WriteCode2($75,$0D); {jne ssdf ;<>}
                             else
                              WriteCode2($72,$03); {jb ssdf ;<}
                            end;
                      '>' : case znak2 of
                              '=' : WriteCode2($73,$03); {jae ssdf ;>=}
                             else
                              WriteCode2($77,$03); {ja ssdf ;>}
                            end;
                      '=' : if znak2='=' then WriteCode2($74,$03); {je ssdf ;=}
                    end;
                    WriteCode3($E9,$00,$00); {jmp addr }
                    LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
                    PVT1:=PositionVarPoint; inc(PositionVarPoint);
                    StrokaVremen:=AnalWord;
                    if StrokaVremen='ТОГДА' then
                      Begin
                        pt:=PositionInFile; StrokaVremen:=AnalWord;
                        if StrokaVremen='НАЧАЛО' then
                          Begin
                            PositionInFile:=pt;
                            Compilator;
                          End
                         Else
                          MesageError(4,StringError(IdentTemp,PosStr));
                      End
                     Else
                      MesageError(12,StringError(IdentTemp,PosStr));

                    WriteCode3($E9,$00,$00); {jmp addr }
                    LabelPoint[PositionVarPoint].Position:=PositionCode-2; {Позиция подстановки}
                    PVT2:=PositionVarPoint; inc(PositionVarPoint);

                    LabelPoint[PVT1].PosPerexod:=PositionCode-2; {Позиция перехода}
                    LabelPoint[PVT1].TypeJmp:=1;
                    pt:=PositionInFile;
                    StrokaVremen:=AnalWord;
                    if StrokaVremen='ИНАЧЕ' then
                      Begin
                        pt:=PositionInFile; StrokaVremen:=AnalWord;
                        if StrokaVremen='НАЧАЛО' then
                          Begin
                            PositionInFile:=pt;
                            Compilator;
                          End
                         Else
                          MesageError(4,StringError(IdentTemp,PosStr));
                      End
                     Else PositionInFile:=pt;

                    LabelPoint[PVT2].PosPerexod:=PositionCode-2; {Позиция перехода}
                    LabelPoint[PVT2].TypeJmp:=1;
                   End
                 Else
                  MesageError(8,StringError(IdentTemp,PosStr));
              End
             Else
              if EsliTerminal(IdentTemp)=4 then
                Begin {Начало}
                  if (BeginTemp>0) and not(StartProg) then
                    MesageError(13,'');
                  StartProg:=True; inc(BeginOpred); inc(BeginTemp);
                  Compilator;
                  flag:=false;
                End
               Else
                if EsliTerminal(IdentTemp)=5 then
                  Begin {Конец}
                    if not(StartProg) or not(BeginEnd) then MesageError(14,'');
                    dec(BeginOpred);
                    if (InStr[PositionInFile]='.') then
                      Begin
                        if BeginOpred=0 then StartProg:=False else MesageError(15,'');
                        WriteCode3($B8,$00,$4C); {Запись команды mov ax,4C00}
                        WriteCode2($CD,$21);     {Запись команды int 21}
                      End;
                    BeginEnd:=False;
                    flag:=false;
                  End
                 Else
                  if EsliTerminal(IdentTemp)=6 then
                    Begin {Печать}
                      If StartProg and (BeginTemp>0) then
                        Begin
                          if InStr[PositionInFile]<>'(' then
                            MesageError(16,StringError(IdentTemp,PosStr));
                          if InStr[PositionInFile+1]='"' then {Если строка}
                            Begin
                              if InStr[PositionInFile+2]<>'"' then
                                WriteStringCode(AnalWord)
                               Else
                                Begin WriteStringCode(''); inc(PositionInFile,2); End;
                              if InStr[PositionInFile]<>'"' then
                                MesageError(17,StringError(IdentTemp,PosStr));
                              If InStr[PositionInFile+2]<>';' then
                                MesageError(6,StringError(IdentTemp,PosStr));
                              inc(PositionInFile,2);
                            End
                           else
                            Begin
                               Code:=PositionInFile;
                               StrokaVremen:=AnalWord;
                               pt:=EsliPerem(StrokaVremen);
                               PositionInFile:=Code;
                               inc(PositionInFile);
                               ViragE;
                               if Variable[pt].TypeVar<>'СИМВОЛ' then
                                 WriteNumberCode(16)
                                Else
                                 Begin
                                   WriteCode3($BA,Lo(Charnews),Hi(Charnews));
                                   WriteCode2($8B,$FA);
                                   WriteCode2($88,$05);
                                   WriteCode2($B4,$09);
                                   WriteCode2($CD,$21);
                                 End;
                               While InStr[PositionInFile]=')' do inc(PositionInFile);
                               If InStr[PositionInFile]<>';' then
                                 MesageError(6,StringError(IdentTemp,PosStr));
                            End;
                        End
                       Else
                        MesageError(8,StringError(IdentTemp,PosStr));
                    End
                   Else
                    if EsliTerminal(IdentTemp)=7 then
                      Begin {Чтение}
                        If StartProg and (BeginTemp>0) then
                          Begin
                            StrokaVremen:=AnalWord;
                            pt:=EsliPerem(StrokaVremen);
                            if pt<>0 then
                              Begin
                                PositionInFile:=PositionInFile-Length(StrokaVremen);
                                ViragE;
                                 if InStr[PositionInFile]<>')' then
                                  MesageError(18,StringError(IdentTemp,PosStr));
                                if InStr[PositionInFile+1]<>';' then
                                  MesageError(6,StringError(IdentTemp,PosStr));
                                if Variable[pt].TypeVar='СИМВОЛ' then ReadCode(10,True) Else ReadCode(10,False);
                              End
                             Else
                              MesageError(5,StringError(IdentTemp,PosStr));
                          End
                         Else
                          MesageError(8,StringError(IdentTemp,PosStr));
                      End
                     Else
                      if EsliTerminal(IdentTemp)=8 then
                        Begin {Определить}
                          If not(StartProg) and (BeginTemp=0) then
                            Begin
                              StrokaVremen:=AnalWord;
                              if EsliPerem(StrokaVremen)=0 then
                                Begin
                                  if InStr[PositionInFile]<>':' then
                                    MesageError(19,StringError(IdentTemp,PosStr));
                                  pt:=EsliType(AnalWord);
                                  if pt<>0 then
                                    Begin
                                      if InStr[PositionInFile]='[' then
                                        Begin
                                          Val(AnalWord,Perevod,Code);
                                          If Code<>0 Then
                                            MesageError(20,StringError(IdentTemp,PosStr));
                                          If InStr[PositionInFile]<>']' then
                                            MesageError(21,StringError(IdentTemp,PosStr));
                                          If InStr[PositionInFile+1]<>';' then
                                            MesageError(6,StringError(IdentTemp,PosStr));
                                          Variable[NewVarPoint].SizeVar:=TypesVar[pt].SizeType*Perevod;
                                        End
                                       Else
                                        Begin
                                          If InStr[PositionInFile]<>';' then
                                            MesageError(6,StringError(IdentTemp,PosStr));
                                          Variable[NewVarPoint].SizeVar:=TypesVar[pt].SizeType;
                                        End;
                                      Variable[NewVarPoint].NameVar:=StrokaVremen;
                                      Variable[NewVarPoint].LabelPoint:=PositionData;
                                      Variable[NewVarPoint].TypeVar:=TypesVar[pt].NameType;
                                      Variable[NewVarPoint].SizeType:=TypesVar[pt].SizeType;
                                      PositionData:=PositionData+Variable[NewVarPoint].SizeVar;
                                      inc(NewVarPoint);
                                    End
                                   Else
                                    MesageError(22,StringError(IdentTemp,PosStr));
                                End
                               Else
                                MesageError(23,StringError(IdentTemp,PosStr));
                            End
                           Else
                            MesageError(24,StringError(IdentTemp,PosStr));
                        End
                       Else
                        if EsliTerminal(IdentTemp)=9 then
                          Begin {НоваяСтрока}
                            If StartProg and (BeginTemp>0) then
                              Begin
                                If InStr[PositionInFile]<>';' then
                                  MesageError(6,StringError(IdentTemp,PosStr));
                                WriteCode3($BA,Lo(Linenews),Hi(Linenews));
                                WriteCode2($B4,$09);
                                WriteCode2($CD,$21);
                              End
                             Else
                              MesageError(24,StringError(IdentTemp,PosStr));
                          End
                         else
                          Begin
                            if InStr[PositionInFile] in ['=','[',';'] then
                              Begin
                                Code:=EsliPerem(IdentTemp);
                                if Code>0 then
                                  Begin
                                    PositionInFile:=PosStr-Length(IdentTemp);
                                    ViragE;
                                    Continue;
                                  End
                                 Else
                                  MesageError(5,StringError(IdentTemp,PosStr));
                              End;
                            if PositionInFile>LengthFile then Exit;
                            MesageError(25,StringError(IdentTemp,PosStr));
                          End;

      End;
  End;

Procedure LabelCalculate; {Расчет меток переходов}
  Var Temp:integer;
      Shift,Smeshen,DataTemp:word;
      i:integer;
  Begin
    Shift:=1+PositionData;
    OutStr[0]:=$E9; OutStr[1]:=Lo(Shift); OutStr[2]:=Hi(Shift); PositionOutFile:=3;
    For i:=0 to PositionData do Begin OutStr[PositionOutFile]:=Data[i]; inc(PositionOutFile); End;
    Smeshen:=PositionOutFile;
    DataTemp:=PositionCode;
    For i:=0 to PositionVarPoint-1 do
      Begin
        if LabelPoint[i].TypeJmp=0 Then
          Temp:=LabelPoint[i].PosPerexod-(LabelPoint[i].Position+Smeshen);
        if LabelPoint[i].TypeJmp=1 Then
          Temp:=LabelPoint[i].PosPerexod-LabelPoint[i].Position;
        PositionCode:=LabelPoint[i].Position;
        WriteCode2(Lo(Temp),Hi(Temp));
      End;
    PositionCode:=DataTemp;
    For i:=0 to PositionCode do Begin OutStr[PositionOutFile]:=Code[i]; inc(PositionOutFile); End;
  End;

Begin
  ClrScr;
  Writeln('Компилятор 1998');
  if ParamCount=1 then FileInput:=ParamStr(1)
   else
    Begin
      WriteLn('Формат вызова COMPILER [Имя файла].liz');  {Если нет параметров}
      Halt(1);
    End;
  FileOutput:=FileInput;
  For i:=1 to length(FileOutput) do if FileOutput[i]='.' then Break;
  FileOutput[0]:=chr(i); FileOutput:=FileOutput+'com';

  PositionOutFile:=0; {Установка начальных значений}
  PositionInFile:=0;
  PositionData:=0;
  PositionCode:=0;
  LengthFile:=0;
  Shift:=$100+3;
  Linenews:=0;
  WrtNum:=0;
  PositionVarPoint:=0;
  NewVarPoint:=1;
  StartProg:=False;
  BeginOpred:=0;
  BeginTemp:=0;
  Charnews:=0; ReadNum:=0; BuffRead:=0;

  Assign(DescriptFile,FileInput); {Загрузка анализируемого файла}
  Reset(DescriptFile,1);
  BlockRead(DescriptFile,InStr,SizeOf(InStr),LengthFile);
  Close(DescriptFile);

  CodeProcedure;  {Запись необюходимых процедур}
  Compilator;     {Компилирование программы}
  LabelCalculate; {Вычисления меток переходов}

  Writeln('Компиляция успешно завершена');
  Writeln('Имя полученного файла = '+FileOutput);
  Assign(DescriptFile,FileOutput); {Запись полученного файла}
  Rewrite(DescriptFile,1);
  BlockWrite(DescriptFile,OutStr,PositionOutFile);
  Close(DescriptFile);
End.