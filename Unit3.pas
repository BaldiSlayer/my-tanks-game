unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Menus, StdCtrls, ImgList, jpeg,
  Vcl.Imaging.pngimage, System.UITypes;

type
  TForm3 = class(TForm)
    Screen: TImage;
    BackScreen: TImage;
    BackGround: TImage;
    Timer1: TTimer;
    Image_implosion_1: TImage;
    Image_implosion_2: TImage;
    Image_implosion_3: TImage;
    Image_implosion_4: TImage;
    Vragov_ostalos: TImage;
    Statistika1: TLabel;
    snaryadov_ostalos: TImage;
    Statistika2: TLabel;
    Statistika4: TLabel;
    Image1: TImage;
    Statistika3: TLabel;
    Lable_Settings_1: TLabel;
    Lable_Settings_2: TLabel;
    Edit_Settings_1: TEdit;
    Edit_Settings_2: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit_Settings_1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_Settings_2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure Edit_Settings_1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit_Settings_2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
    TPlayer = record
    x1, y1, x2, y2: integer;
    zvet, health, perezaryadka, speed, height, width, poloschenie_tanka: byte; //параметры тарелки, poloschenie_tanka_igroka - 1 - дулом вверх, 2 - дулом вниз, 3 - дулом направо, 4 - дулом налево
    perzaryaschen: boolean;
    end;

    TEnemy = record
    x1, y1, x2, y2: integer; // координаты
    proehal: boolean; // активность
    health, type_of_tank, perezaryadka, skorost: byte;
    end;

    TPulia = record
    x1, y1, x2, y2: integer; // координаты
    enabled: boolean; // активность
    napravlenie, damage: byte; //направление полета пули
    end;

    TVzriv = record
    x, y, enemy_number: integer; // координаты
    etap: byte; // стадия отрисовки взрыва
    end;

const
  vzrivi_count = 50;
  puli_vraga_count = 100;
  vragi_count = 20;
  nachalinie_koordinati_statistiki_x = 692;
  nachalinie_koordinati_statistiki_y = 60;
  kolishestwo_settings = 2;

var
  Form3: TForm3;
 // x, y: integer;


  schitano: boolean;

  sozdano_igrokov, nushnoe_napravlenie: byte;

  players: array [1..2] of TPlayer;

  puli: array [1..100] of TPulia;

  puli_vraga: array [1..puli_vraga_count] of TPulia;

  vragi: array [1..20] of TEnemy;

  vzrivi: array [1..vzrivi_count] of TVzriv;
  file_path, image_path, path, settings_image_path: string;

  skorost_pt_sau, skorost_legkogo_tanka, skorost_srednego_tanka: byte;
  takt, sdelano_vistrelov, chastota_poyavlenya: byte;
  neobchodimo_zamochit, vragov_propuscheno: byte;
  tekst_x, tekst_y:  integer;
  sozdano_vragov: integer;
  veroyatnost_sredniy_tank, veroyatnost_pt_sau: byte;
  skorost_snaryada: byte;
  perezaryadka_tanka_vraga: integer;
  level, dostupno_vistrelov, limit_propuskov, vragov_ubito: byte; //статистика

  zapuskalsya, blischaischi_vrag_izmenilsya: boolean;
  rasstoyanie_do_blishaishego_vraga: integer;//vremya_do_vstreshi, время когда через которое танк врага и танк игрока(заставка) будут на одной линии

  vremya_do_vistrela: real;

  nomer_blishaishego_vraga, predpologaemoe_health: byte;


 vremya_poleta_snaryada, vremya_do_vstreshi: real;
 first_player_shot_key, second_player_shot_key: word;
 Settings_on, elementi_sozdani: boolean;
 perezaryadka_player: byte;
implementation

{$R *.dfm}


procedure Settings();
var y: byte;
   n: integer;
begin
   Settings_on := True;
   Form3.BackGround.Picture.Bitmap := nil;
   Form3.BackGround.Picture.LoadFromFile(settings_image_path);
   Form3.Statistika1.Visible := False;
   Form3.Statistika2.Visible := False;
   Form3.Statistika3.Visible := False;
   Form3.Statistika4.Visible := False;

   Form3.Button1.Visible := True;
   Form3.Button2.Visible := True;


   Form3.Edit_Settings_1.Visible := True;
   Form3.Edit_Settings_2.Visible := True;

   Form3.Lable_Settings_1.Visible := True;
   Form3.Lable_Settings_2.Visible := True;

   if (first_player_shot_key = 32) or (first_player_shot_key = 17) or (first_player_shot_key = 18) or (first_player_shot_key = 91) then
      case first_player_shot_key of
          32: Form3.Edit_Settings_1.Text := 'SPACE';
          17: Form3.Edit_Settings_1.Text := 'CTRL';
          18: Form3.Edit_Settings_1.Text := 'ALT';
          91: Form3.Edit_Settings_1.Text := 'WIN';
      end
   else Form3.Edit_Settings_1.Text := chr(first_player_shot_key);

   if (second_player_shot_key = 32) or (second_player_shot_key = 17) or (second_player_shot_key = 18) or (second_player_shot_key = 91) then
      case second_player_shot_key of
          32: Form3.Edit_Settings_2.Text := 'SPACE';
          17: Form3.Edit_Settings_2.Text := 'CTRL';
          18: Form3.Edit_Settings_2.Text := 'ALT';
          91: Form3.Edit_Settings_2.Text := 'WIN';
      end
   else Form3.Edit_Settings_2.Text := chr(second_player_shot_key);

   Form3.Lable_Settings_1.Caption := 'Кнопка выстрела первого игрока';
   Form3.Lable_Settings_2.Caption := 'Кнопка выстрела второго игрока';

   //кнопка выстрела первого игрока
   Form3.Edit_Settings_1.Left := 300;
   Form3.Edit_Settings_1.Top := 50;
   Form3.Lable_Settings_1.Left := 100;
   Form3.Lable_Settings_1.Top := 50;


   Form3.Edit_Settings_2.Left := 300;
   Form3.Edit_Settings_2.Top := 100;
   Form3.Lable_Settings_2.Left := 100;
   Form3.Lable_Settings_2.Top := 100;
end;

procedure Statistika();
begin
    form3.Caption:= 'Танки (Уровень: '+ IntToStr(level) +
      '. Здоровье: ' + inttostr(players[1].health) +
      '. Врагов убито: ' + inttostr(vragov_ubito) +
      ' из ' + IntToStr(neobchodimo_zamochit) +
      '. Врагов пролетело: ' + inttostr(vragov_propuscheno) + ' из ' + IntToStr(limit_propuskov) + ')'
      + 'Перезарядка' + IntToStr((perezaryadka_player * 50) - (players[1].perezaryadka * 50));

    Form3.Statistika1.Caption := IntToStr(neobchodimo_zamochit - vragov_ubito);

    Form3.Statistika2.Caption := IntToStr(dostupno_vistrelov - sdelano_vistrelov);

    Form3.Statistika4.Caption := 'Level ' + IntToStr(level);

    Form3.Statistika3.Caption := IntToStr(vragov_propuscheno);
end;

//враг
procedure Create_Enemy();
var k, g: byte;
begin
  sozdano_vragov := sozdano_vragov + 1;
  for k := 1 to 20 do
      if vragi[k].health = 0 then
        begin

          //убираю все взрывы от танка с данным номером
          for g := 1 to 50 do
            if (k = vzrivi[g].enemy_number) and (vragi[k].proehal) then
              vzrivi[g].etap := 0;


          //присвоение начальных значений координат врага
          if sozdano_vragov mod veroyatnost_sredniy_tank = 0 then
            begin
              vragi[k].health := 2;
              vragi[k].type_of_tank := 2;
              vragi[k].skorost := skorost_srednego_tanka;
            end;
          if sozdano_vragov mod veroyatnost_pt_sau = 0 then
          begin
                vragi[k].health := 3;
                vragi[k].type_of_tank := 3;
                vragi[k].skorost := skorost_pt_sau;
          end
          else if (sozdano_vragov mod veroyatnost_sredniy_tank <> 0) and (sozdano_vragov mod veroyatnost_pt_sau <> 0) then
             begin
                vragi[k].health := 1;
                vragi[k].type_of_tank := 1;
                vragi[k].skorost := skorost_legkogo_tanka;
             end;
          vragi[k].x1 := random(Form3.BackScreen.Width - 35 - 175) + 35 div 2;  //35 пикселей - размеры танка
          vragi[k].x2 := vragi[k].x1 + 7 * 5;
          vragi[k].y1 := -34;
          vragi[k].y2 := 1;
          break;
        end;
end;

procedure Zastavka();
begin
            if level = 0 then
                begin
                    dostupno_vistrelov := 30;
                    neobchodimo_zamochit := 5;
                    chastota_poyavlenya := 40;//2 сек
                    players[1].speed := 4;
                    if sozdano_igrokov = 2 then
                        players[2].speed := 4;

                    limit_propuskov := 100;
                    skorost_snaryada := 10;
                    players[1].health:= 5;


                    sozdano_igrokov := 1;
                    players[1].x1 := Form3.BackScreen.Width div 2;
                    players[1].y1 := Form3.Height - 50;

                    veroyatnost_sredniy_tank := 5;
                    veroyatnost_pt_sau := 10;

                    tekst_x := Form3.Screen.Width div 2 - 50;
                    tekst_y := Form3.Screen.Height div 2 - 50;
                    Form3.BackGround.Canvas.Font.Size := 34;
                    Form3.BackGround.Canvas.Font.Color := clBlack;
                    Form3.BackGround.Canvas.Brush.Style := bsClear;
                    Form3.BackGround.Canvas.TextOut(235, 125, '1 игрок');
                    Form3.BackGround.Canvas.TextOut(220, 185, '2 игрока'); //сделать переменные
                    Form3.BackGround.Canvas.TextOut(200, 245, 'Настройки');
                    Statistika();
                    Form3.Timer1.Enabled := True;
                end;

end;

procedure schitivanie_s_file;
var F: Text;
begin
   path := ExtractFilePath(ParamStr(0));
   file_path := ExtractFilePath(ParamStr(0)) + 'Settings.txt';
   image_path := ExtractFilePath(ParamStr(0)) + 'Трава.bmp';
   settings_image_path := ExtractFilePath(ParamStr(0)) + 'Танк.bmp';
   Assign(F, file_path);
   Reset(F);
   if not EOF(F) Then
    begin
      readln(F, skorost_legkogo_tanka);
      readln(F, skorost_srednego_tanka);
      readln(F, skorost_pt_sau);
    end;

   Close(F);
end;

//создание пули врага
procedure Sozdanie_puli_vraga(x: byte);
var p: byte;
begin
     for p := 1 to puli_vraga_count do
      if not puli_vraga[p].enabled then
        begin
               //присвоение начальных значений координат снаряда
               puli_vraga[p].x1 := vragi[x].x1 + 35 div 2 + 3;//3 - половина ширины снаряда, 35 - ширина танка
               puli_vraga[p].x2 := puli_vraga[p].x1 + 6;// 6 ширина снаряда
               puli_vraga[p].y1 := vragi[x].y2 + 2 * 5;//11 - высота снаряда
               puli_vraga[p].y2 := vragi[x].y2 + 2 * 5 + 11;
               puli_vraga[p].enabled := True;
               puli_vraga[p].napravlenie := 2;
               break;
        end;
end;

procedure Clean_Enemy_number(enemy_number: byte);
var i: byte;
begin
  for i := 1 to vzrivi_count do
    if (vzrivi[i].enemy_number = enemy_number) and (vzrivi[i].etap > 0) then
      begin
          vragi[enemy_number].perezaryadka := 0;
          vzrivi[i].enemy_number := 0;
          vzrivi[i].x := vzrivi[i].x + vragi[enemy_number].x1;
          vzrivi[i].y := vzrivi[i].y + vragi[enemy_number].y1;
      end;
end;

procedure New_Level();
var y: byte;
begin
  schitano := False;
  players[1].poloschenie_tanka := 1;
  if sozdano_igrokov = 2 then
      players[2].poloschenie_tanka := 1;

  for y := 1 to 20 do
      if puli[y].enabled then
        puli[y].enabled := False;


  for y := 1 to 20 do
    begin
      vragi[y].perezaryadka := 0;
      if vragi[y].health > 0 then
        vragi[y].health := 0;
    end;

  for y := 1 to vzrivi_count do
   if vzrivi[y].etap > 0 then
        vzrivi[y].etap := 0;

   for y := 1 to puli_vraga_count do
   if puli_vraga[y].enabled then
        puli_vraga[y].enabled := False;


  sozdano_vragov := 0;
  players[1].perezaryadka := perezaryadka_player;
  if sozdano_igrokov = 2 then
      players[2].perezaryadka := perezaryadka_player;
//  sozdano_igrokov := 1;
  case level of

    0:
      begin
          Zastavka();
          perezaryadka_player := 30;
      end;

    1:
      begin
          dostupno_vistrelov := 30;
          neobchodimo_zamochit := 5;
          chastota_poyavlenya := 80;//4 сек

          players[1].speed := 4;
          if sozdano_igrokov = 2 then
            players[2].speed := 4;

          if sozdano_igrokov = 2 then
          limit_propuskov := 5;
          skorost_snaryada := 10;
          players[1].health:= 5;
          if sozdano_igrokov = 2 then
              players[2].health:= 5;

          veroyatnost_sredniy_tank := 100; // каждый 100-ый танк средний (недостижимо на 1ом уровне)
          veroyatnost_pt_sau := 100;
          perezaryadka_player := 30;
      end;
    2:
      begin
          dostupno_vistrelov := 30;
          neobchodimo_zamochit := 10;
          chastota_poyavlenya := 70;//3.5 сек
          //skorost_vraga := 3;


          players[1].speed := 4;
          if sozdano_igrokov = 2 then
            players[2].speed := 4;


          limit_propuskov := 5;
          skorost_snaryada := 11;
          players[1].health:= 5;
          if sozdano_igrokov = 2 then
              players[2].health:= 5;

          veroyatnost_sredniy_tank := 10; // каждый 10-ый танк средний
          veroyatnost_pt_sau := 100;
          perezaryadka_player := 30;

      end;
    3:
      begin
          dostupno_vistrelov := 40;
          neobchodimo_zamochit := 15;
          chastota_poyavlenya := 60;//3 сек

          players[1].speed := 5;
          if sozdano_igrokov = 2 then
            players[2].speed := 5;

          limit_propuskov := 6;
          skorost_snaryada := 12;
          players[1].health:= 6;
          if sozdano_igrokov = 2 then
              players[2].health:= 6;

          veroyatnost_sredniy_tank := 5; // каждый 5-ый танк средний
          veroyatnost_pt_sau := 100;
          perezaryadka_player := 20;
      end;
    4:
      begin
          dostupno_vistrelov := 40;
          neobchodimo_zamochit := 20;
          chastota_poyavlenya := 50;//2.5 сек

         players[1].speed := 6;
          if sozdano_igrokov = 2 then
            players[2].speed := 6;


          limit_propuskov := 7;
          skorost_snaryada := 13;
          players[1].health:= 7;
          if sozdano_igrokov = 2 then
              players[2].health:= 7;

          veroyatnost_sredniy_tank := 3; // каждый 3-ий танк средний
          veroyatnost_pt_sau := 100;
          perezaryadka_player := 15;
      end;
    5:
      begin
          dostupno_vistrelov := 60;
          neobchodimo_zamochit := 25;
          chastota_poyavlenya := 50;//2 сек

          players[1].speed := 7;
          if sozdano_igrokov = 2 then
            players[2].speed := 7;


          limit_propuskov := 8;
          skorost_snaryada := 14;
          players[1].health:= 9;
          if sozdano_igrokov = 2 then
              players[2].health:= 9;

          veroyatnost_sredniy_tank := 1;
           veroyatnost_pt_sau := 100;
           perezaryadka_player := 10;
      end;

    6:
      begin
          dostupno_vistrelov := 75;
          neobchodimo_zamochit := 30;
          chastota_poyavlenya := 60;//3 сек

          players[1].speed := 6;
          if sozdano_igrokov = 2 then
            players[2].speed := 6;


          limit_propuskov := 8;
          skorost_snaryada := 14;
          players[1].health:= 10;
          if sozdano_igrokov = 2 then
              players[2].health:= 10;

          veroyatnost_sredniy_tank := 1;
          veroyatnost_pt_sau := 30;
          perezaryadka_player := 10;
      end;
  end;

  if level <> 0 then
      begin
          perezaryadka_tanka_vraga := 100;
          sdelano_vistrelov := 0;
          vragov_ubito := 0;
          takt := 0;
          vragov_propuscheno := 0;
          players[1].perezaryadka := 0;

          players[1].perzaryaschen := False;
          if sozdano_igrokov = 2 then
              players[2].perzaryaschen := False;

          if sozdano_igrokov = 2 then
              players[2].perezaryadka := 0;

          Statistika();
          Form3.Timer1.Enabled := True;
          Form3.BackGround.Picture.Bitmap := nil;
          Form3.BackGround.Picture.LoadFromFile(image_path);
      end;
end;

procedure Proverka();
  var buttonSelected: integer;
      soobchenie: string;
begin
      if vragov_ubito >= neobchodimo_zamochit then
          begin
              Form3.Timer1.Enabled := False;
              soobchenie := 'Молодец, вторжение остановлено!' + #10#13 + 'Переходим на следующий уровень?';
              buttonSelected := MessageDlg(soobchenie, mtInformation, mbYesNo, 0);
              if buttonSelected = mrYes then
                begin
                  level := level + 1;
                  New_Level();
                end;
          end
      else if vragov_propuscheno >= limit_propuskov then
              begin
                Form3.Timer1.Enabled := False;
                soobchenie := 'Игра проиграна! Вторжение не остановлено.' + #10#13 + 'Начнём сначала?';
                buttonSelected := MessageDlg(soobchenie, mtCustom, mbYesNo, 0);
                if buttonSelected = mrYes then
                   begin
                    level := 1;
                    New_Level();
                   end;
              end

          else if dostupno_vistrelov - sdelano_vistrelov = 0 then
              begin
                Form3.Timer1.Enabled := False;
                soobchenie := 'Игра проиграна! Снарядов больше нет.' + #10#13 + 'Начнём сначала?';
                buttonSelected := MessageDlg(soobchenie, mtCustom, mbYesNo, 0);
                if buttonSelected = mrYes then
                    begin
                      level := 1;
                      New_Level();
                    end;
              end;


             if sozdano_igrokov = 0 then
                begin
                    if players[1].health = 0 then
                        begin
                        Form3.Timer1.Enabled := False;
                        soobchenie := 'Игра проиграна! Вас убили.' + #10#13 + 'Начнём сначала?';
                        buttonSelected := MessageDlg(soobchenie, mtCustom, mbYesNo, 0);
                        if buttonSelected = mrYes then
                            begin
                                level := 1;
                                New_Level();
                            end;
                        end;
                end
             else
                begin
                  if (players[1].health = 0) and (players[2].health = 0) then
                      begin
                        Form3.Timer1.Enabled := False;
                        soobchenie := 'Игра проиграна! Вас убили.' + #10#13 + 'Начнём сначала?';
                        buttonSelected := MessageDlg(soobchenie, mtCustom, mbYesNo, 0);
                        if buttonSelected = mrYes then
                            begin
                                level := 1;
                                New_Level();
                            end;
                      end;
                end;
end;

procedure Create_Vzriv(x_vzriv, y_vzriv: integer; enemy_number: integer = 0);
var v: byte;
begin
    for v := 1 to vzrivi_count do
        if vzrivi[v].etap = 0 then
            begin
                   vzrivi[v].etap := 35;
                   vzrivi[v].enemy_number := enemy_number;
                   vzrivi[v].x := x_vzriv;
                   vzrivi[v].y := y_vzriv;
                   break;
            end;
end;

procedure Popadanie_snaryada_igroka(i: integer);
var popadanie_x, popadanie_y:boolean;
    j: integer;
begin
     for j := 1 to 20 do
     begin
         if vragi[j].health > 0 then
             begin
                 popadanie_x := (((vragi[j].x1 <= puli[i].x1) and (puli[i].x1 <= vragi[j].x2)) or ((vragi[j].x1 <= puli[i].x2) and (puli[i].x2 <= vragi[j].x2)));
                 popadanie_y := (((vragi[j].y1 <= puli[i].y1) and (puli[i].y1 <= vragi[j].y2)) or ((vragi[j].y1 <= puli[i].y2) and (puli[i].y2 <= vragi[j].y2)));
                 if popadanie_x and popadanie_y then
                     begin
                         puli[i].enabled := False;
                         vragi[j].health := vragi[j].health - 1;
                         if vragi[j].health <= 0 then
                             begin
                                 vragov_ubito := vragov_ubito + 1;
                                 Statistika();
                                 Clean_Enemy_number(j);
//                                 if puli[i].napravlenie <> 3 then
//                                    Create_Vzriv(puli[i].x1 - 5, puli[i].y1)  //не указываю последний параметр, т.к. он стоит по умолчанию
//                                 else Create_Vzriv(puli[i].x1 + 5, puli[i].y1);
                                 Create_Vzriv(puli[i].x1, puli[i].y1);
                                 vragi[i].perezaryadka := 0;
                                 if level = 0 then
                                 zapuskalsya := False;
                             end
                         else
                             begin
                                Create_Vzriv((puli[i].x1 - 5) - vragi[j].x1, (puli[i].y1  - vragi[j].y1), j); //координаты относительно x1 и y1
                             end;
                     end;
         end;//for j := 1 to 20 do
    end;
end;

procedure Risovanie_snaryda(vrag: boolean; number: integer);
var snaryad_points_up_and_down: array [1..10] of TPoint;
    snaryad_points_left_and_right: array [1..8] of TPoint;
    snaryad_vraga: array [1..10] of TPoint;
begin
                       Form3.BackScreen.Canvas.Pen.Color := clBlack;
                       Form3.BackScreen.Canvas.Brush.Color := clDkGray;
                       if not vrag then
                          begin
                              case puli[number].napravlenie of
                              1:  //вверх
                                begin
                                  snaryad_points_up_and_down[1].X := puli[number].x2 - 2;           snaryad_points_up_and_down[1].Y := puli[number].y2;
                                  snaryad_points_up_and_down[2].X := puli[number].x1;               snaryad_points_up_and_down[2].Y := puli[number].y2;
                                  snaryad_points_up_and_down[3].X := puli[number].x1;               snaryad_points_up_and_down[3].Y := puli[number].y2 - 5;
                                  snaryad_points_up_and_down[4].X := puli[number].x1 + 1;           snaryad_points_up_and_down[4].Y := puli[number].y2 - 8;
                                  snaryad_points_up_and_down[5].X := puli[number].x1 + 1;           snaryad_points_up_and_down[5].Y := puli[number].y2 - 11;
                                  snaryad_points_up_and_down[6].X := puli[number].x1 + 2;           snaryad_points_up_and_down[6].Y := puli[number].y1 - 2;
                                  snaryad_points_up_and_down[7].X := puli[number].x1 + 3;           snaryad_points_up_and_down[7].Y := puli[number].y2 - 11;
                                  snaryad_points_up_and_down[8].X := puli[number].x1 + 3;           snaryad_points_up_and_down[8].Y := puli[number].y2 - 8;
                                  snaryad_points_up_and_down[9].X := puli[number].x2 - 2;           snaryad_points_up_and_down[9].Y := puli[number].y2 - 5;
                                  snaryad_points_up_and_down[10].X := puli[number].x2 - 2;          snaryad_points_up_and_down[10].Y := puli[number].y2;
                                  Form3.BackScreen.Canvas.Polygon(snaryad_points_up_and_down);
                                end;

                              2:  //вниз
                                begin
                                  snaryad_points_up_and_down[1].X := puli[number].x1;               snaryad_points_up_and_down[1].Y := puli[number].y1;
                                  snaryad_points_up_and_down[2].X := puli[number].x1;               snaryad_points_up_and_down[2].Y := puli[number].y1 + 5;
                                  snaryad_points_up_and_down[3].X := puli[number].x1 + 1;           snaryad_points_up_and_down[3].Y := puli[number].y1 + 8;
                                  snaryad_points_up_and_down[4].X := puli[number].x1 + 1;           snaryad_points_up_and_down[4].Y := puli[number].y1 + 11;
                                  snaryad_points_up_and_down[5].X := puli[number].x1 + 2;           snaryad_points_up_and_down[5].Y := puli[number].y2;
                                  snaryad_points_up_and_down[6].X := puli[number].x1 + 3;           snaryad_points_up_and_down[6].Y := puli[number].y1 + 11;
                                  snaryad_points_up_and_down[7].X := puli[number].x1 + 3;           snaryad_points_up_and_down[7].Y := puli[number].y1 + 8;
                                  snaryad_points_up_and_down[8].X := puli[number].x2 - 2;           snaryad_points_up_and_down[8].Y := puli[number].y1 + 5;
                                  snaryad_points_up_and_down[9].X := puli[number].x2 - 2;           snaryad_points_up_and_down[9].Y := puli[number].y1;
                                  snaryad_points_up_and_down[10].X := puli[number].x1;              snaryad_points_up_and_down[10].Y := puli[number].y1;
                                  Form3.BackScreen.Canvas.Polygon(snaryad_points_up_and_down);
                                end;

                              3:   //право
                                begin
                                  snaryad_points_left_and_right[1].X := puli[number].x1;               snaryad_points_left_and_right[1].Y := puli[number].y1;
                                  snaryad_points_left_and_right[2].X := puli[number].x1 + 5;           snaryad_points_left_and_right[2].Y := puli[number].y1;
                                  snaryad_points_left_and_right[3].X := puli[number].x1 + 9;           snaryad_points_left_and_right[3].Y := puli[number].y1 + 1;
                                  snaryad_points_left_and_right[4].X := puli[number].x2 + 2;           snaryad_points_left_and_right[4].Y := puli[number].y1 + 2;
                                  snaryad_points_left_and_right[5].X := puli[number].x1 + 9;           snaryad_points_left_and_right[5].Y := puli[number].y1 + 3;
                                  snaryad_points_left_and_right[6].X := puli[number].x1 + 5;           snaryad_points_left_and_right[6].Y := puli[number].y2;
                                  snaryad_points_left_and_right[7].X := puli[number].x1;               snaryad_points_left_and_right[7].Y := puli[number].y2;
                                  snaryad_points_left_and_right[8].X := puli[number].x1;               snaryad_points_left_and_right[8].Y := puli[number].y2;
                                  Form3.BackScreen.Canvas.Polygon(snaryad_points_left_and_right);                              snaryad_points_left_and_right[8].Y := puli[number].y1;
                                end;

                              4: //лево
                                begin
                                  snaryad_points_left_and_right[1].X := puli[number].x2;               snaryad_points_left_and_right[1].Y := puli[number].y2;
                                  snaryad_points_left_and_right[2].X := puli[number].x2 - 5;           snaryad_points_left_and_right[2].Y := puli[number].y2;
                                  snaryad_points_left_and_right[3].X := puli[number].x2 - 9;           snaryad_points_left_and_right[3].Y := puli[number].y2 - 1;
                                  snaryad_points_left_and_right[4].X := puli[number].x1 - 2;           snaryad_points_left_and_right[4].Y := puli[number].y2 - 2;
                                  snaryad_points_left_and_right[5].X := puli[number].x2 - 9;           snaryad_points_left_and_right[5].Y := puli[number].y2 - 3;
                                  snaryad_points_left_and_right[6].X := puli[number].x2 - 5;           snaryad_points_left_and_right[6].Y := puli[number].y1;
                                  snaryad_points_left_and_right[7].X := puli[number].x2;               snaryad_points_left_and_right[7].Y := puli[number].y1;
                                  snaryad_points_left_and_right[8].X := puli[number].x2;               snaryad_points_left_and_right[8].Y := puli[number].y2;
                                  Form3.BackScreen.Canvas.Polygon(snaryad_points_left_and_right);
                                end;
                              end;
                          end
                       else
                          begin
                                  Form3.BackScreen.Canvas.Pen.Color := clBlack;
                                  Form3.Brush.Color := clDkGray;
                                  case puli_vraga[number].napravlenie of
                                  1:  //вверх
                                    begin
                                      snaryad_points_up_and_down[1].X := puli_vraga[number].x2 - 2;           snaryad_points_up_and_down[1].Y := puli_vraga[number].y2;
                                      snaryad_points_up_and_down[2].X := puli_vraga[number].x1;               snaryad_points_up_and_down[2].Y := puli_vraga[number].y2;
                                      snaryad_points_up_and_down[3].X := puli_vraga[number].x1;               snaryad_points_up_and_down[3].Y := puli_vraga[number].y2 - 5;
                                      snaryad_points_up_and_down[4].X := puli_vraga[number].x1 + 1;           snaryad_points_up_and_down[4].Y := puli_vraga[number].y2 - 8;
                                      snaryad_points_up_and_down[5].X := puli_vraga[number].x1 + 1;           snaryad_points_up_and_down[5].Y := puli_vraga[number].y2 - 11;
                                      snaryad_points_up_and_down[6].X := puli_vraga[number].x1 + 2;           snaryad_points_up_and_down[6].Y := puli_vraga[number].y1 - 2;
                                      snaryad_points_up_and_down[7].X := puli_vraga[number].x1 + 3;           snaryad_points_up_and_down[7].Y := puli_vraga[number].y2 - 11;
                                      snaryad_points_up_and_down[8].X := puli_vraga[number].x1 + 3;           snaryad_points_up_and_down[8].Y := puli_vraga[number].y2 - 8;
                                      snaryad_points_up_and_down[9].X := puli_vraga[number].x2 - 2;           snaryad_points_up_and_down[9].Y := puli_vraga[number].y2 - 5;
                                      snaryad_points_up_and_down[10].X := puli_vraga[number].x2 - 2;          snaryad_points_up_and_down[10].Y := puli_vraga[number].y2;
                                      Form3.BackScreen.Canvas.Polygon(snaryad_points_up_and_down);
                                    end;

                                  2:  //вниз
                                    begin
                                      snaryad_points_up_and_down[1].X := puli_vraga[number].x1;               snaryad_points_up_and_down[1].Y := puli_vraga[number].y1;
                                      snaryad_points_up_and_down[2].X := puli_vraga[number].x1;               snaryad_points_up_and_down[2].Y := puli_vraga[number].y1 + 5;
                                      snaryad_points_up_and_down[3].X := puli_vraga[number].x1 + 1;           snaryad_points_up_and_down[3].Y := puli_vraga[number].y1 + 8;
                                      snaryad_points_up_and_down[4].X := puli_vraga[number].x1 + 1;           snaryad_points_up_and_down[4].Y := puli_vraga[number].y1 + 11;
                                      snaryad_points_up_and_down[5].X := puli_vraga[number].x1 + 2;           snaryad_points_up_and_down[5].Y := puli_vraga[number].y2;
                                      snaryad_points_up_and_down[6].X := puli_vraga[number].x1 + 3;           snaryad_points_up_and_down[6].Y := puli_vraga[number].y1 + 11;
                                      snaryad_points_up_and_down[7].X := puli_vraga[number].x1 + 3;           snaryad_points_up_and_down[7].Y := puli_vraga[number].y1 + 8;
                                      snaryad_points_up_and_down[8].X := puli_vraga[number].x2 - 2;           snaryad_points_up_and_down[8].Y := puli_vraga[number].y1 + 5;
                                      snaryad_points_up_and_down[9].X := puli_vraga[number].x2 - 2;           snaryad_points_up_and_down[9].Y := puli_vraga[number].y1;
                                      snaryad_points_up_and_down[10].X := puli_vraga[number].x1;              snaryad_points_up_and_down[10].Y := puli_vraga[number].y1;
                                      Form3.BackScreen.Canvas.Polygon(snaryad_points_up_and_down);
                                    end;

                                  3:   //право
                                    begin
                                      snaryad_points_left_and_right[1].X := puli_vraga[number].x1;                  snaryad_points_left_and_right[1].Y := puli_vraga[number].y1;
                                      snaryad_points_left_and_right[2].X := puli_vraga[number].x1 + 5;              snaryad_points_up_and_down[2].Y := puli_vraga[number].y1;
                                      snaryad_points_left_and_right[3].X := puli_vraga[number].x1 + 9;              snaryad_points_up_and_down[3].Y := puli_vraga[number].y1 + 1;
                                      snaryad_points_left_and_right[4].X := puli_vraga[number].x2 + 2;              snaryad_points_up_and_down[4].Y := puli_vraga[number].y1 + 2;
                                      snaryad_points_left_and_right[5].X := puli_vraga[number].x1 + 9;              snaryad_points_up_and_down[5].Y := puli_vraga[number].y1 + 3;
                                      snaryad_points_left_and_right[6].X := puli_vraga[number].x1 + 5;              snaryad_points_up_and_down[6].Y := puli_vraga[number].y2;
                                      snaryad_points_left_and_right[7].X := puli_vraga[number].x1;                  snaryad_points_up_and_down[7].Y := puli_vraga[number].y2;
                                      snaryad_points_left_and_right[8].X := puli_vraga[number].x1;                  snaryad_points_up_and_down[8].Y := puli_vraga[number].y2;
                                      Form3.BackScreen.Canvas.Polygon(snaryad_points_left_and_right);               snaryad_points_up_and_down[8].Y := puli[number].y1;
                                    end;

                                  4: //лево
                                    begin
                                      snaryad_points_left_and_right[1].X := puli_vraga[number].x2;               snaryad_points_left_and_right[1].Y := puli_vraga[number].y2;
                                      snaryad_points_left_and_right[2].X := puli_vraga[number].x2 - 5;           snaryad_points_left_and_right[2].Y := puli_vraga[number].y2;
                                      snaryad_points_left_and_right[3].X := puli_vraga[number].x2 - 9;           snaryad_points_left_and_right[3].Y := puli_vraga[number].y2 - 1;
                                      snaryad_points_left_and_right[4].X := puli_vraga[number].x1 - 2;           snaryad_points_left_and_right[4].Y := puli_vraga[number].y2 - 2;
                                      snaryad_points_left_and_right[5].X := puli_vraga[number].x2 - 9;           snaryad_points_left_and_right[5].Y := puli_vraga[number].y2 - 3;
                                      snaryad_points_left_and_right[6].X := puli_vraga[number].x2 - 5;           snaryad_points_left_and_right[6].Y := puli_vraga[number].y1;
                                      snaryad_points_left_and_right[7].X := puli_vraga[number].x2;               snaryad_points_left_and_right[7].Y := puli_vraga[number].y1;
                                      snaryad_points_left_and_right[8].X := puli_vraga[number].x2;               snaryad_points_left_and_right[8].Y := puli_vraga[number].y2;
                                      Form3.BackScreen.Canvas.Polygon(snaryad_points_left_and_right);
                                    end;
                                  end;
                           end;
end;

procedure Popadanie_snaryada_vraga();
var  popadanie_x, popadanie_y: boolean;
     i, r: integer;
begin
//проверка попадания пули врага в игрока(игроков)
    for r := 1 to sozdano_igrokov do                                  //перебор танков игрока (игроков)
        for i := 1 to puli_vraga_count do
            begin
                 if puli_vraga[i].enabled then
                 begin
                     popadanie_x := (((players[r].x1 <= puli_vraga[i].x1) and (puli_vraga[i].x1 <= players[r].x2)) or ((players[r].x1 <= puli_vraga[i].x2) and (puli_vraga[i].x2 <= players[r].x2)));
                     popadanie_y := ((players[r].y2 <= puli_vraga[i].y1) and (puli_vraga[i].y1 <= players[r].y1)) or ((players[r].y2 <= puli_vraga[i].y2) and (puli_vraga[i].y2 <= players[r].y1));
                     if popadanie_x and popadanie_y then
                        begin
                             players[r].health := players[r].health - 1;
                             puli_vraga[i].enabled := False;
                             Create_Vzriv(puli_vraga[i].x1 - 5, puli_vraga[i].y1);
                             Statistika();
                             Proverka();
                             players[r].x1 := Form3.BackScreen.Width div 2;
                             players[r].y1 := Form3.Height - 50;
                             players[r].poloschenie_tanka := 1;
                             break;
                        end;
                 end;
            end;
end;

procedure Risovanie_Tanka(x, y: integer; type_of_tank: byte; enemy: Boolean);
var m: byte;
begin
with Form3.BackScreen.Canvas do
if enemy then
begin
              begin
                    Brush.Color := clGray;
                    case type_of_tank of
                    1:  //легкий танк
                      begin
                        Rectangle(x + 1 * 5, y - 6 * 5, x + 8 * 5, y - 1 * 5); //основной корпус
                        Rectangle(x + 3 * 5, y - 5 * 5, x + 5 * 6, y - 2 * 5);  //башня
                        Rectangle(x + 4 * 5, y - (2 * 5) - 1, x + 5 * 5 , y + 1 * 5); //пушка
                      end;

                    2:// средний танк
                      begin
                        Rectangle(x + 1 * 5, y - 7 * 5, x + 8 * 5, y); //основной корпус
                        Rectangle(x + 3 * 5, y - 5 * 5, x + 5 * 6, y - 2 * 5);  //башня
                        Rectangle(x + 4 * 5, y - (2 * 5) - 1, x + 5 * 5 , y + 2 * 5); //пушка
                      end;

                    3:  //пт сау
                      begin
                        Rectangle(x + 1 * 5, y - 7 * 5, x + 8 * 5, y); //основной корпус
                        Rectangle(x + (3 * 5) - 3, y - 7 * 5, x + (5 * 6) + 3, y - 3 * 5);  //башня
                        Rectangle(x + (4 * 5) - 2, y - (3 * 5) - 1, x + (5 * 5) + 2, y + 1 * 5); //пушка
                      end;
                    end;


                      //гусеницы
                      Brush.Color := clBlack;
                      Rectangle(x + 1 * 5, y - 7 * 5, x + 2 * 5, y);
                      Rectangle(x + 7 * 5, y - 7 * 5, x + 8 * 5, y);
              end;
 end
else
    begin
        begin
            CopyRect(Rect(0,0,Screen.Width, Screen.Height), Form3.BackGround.Canvas, Rect(0,0,Screen.Width, Screen.Height));
            //отрисовка танка
            for m := 1 to sozdano_igrokov do
            begin

                case players[m].zvet of
                    0, 5: Brush.Color := clOlive;
                    1: Brush.Color := clGreen;
                    2: Brush.Color := clWhite;
                    3: Brush.Color := clRed;
                    4: Brush.Color := clYellow;
                end;

                Rectangle(players[m].x1 + 1 * 5, players[m].y1 - 7 * 5, players[m].x1 + 8 * 5, players[m].y1);
                Rectangle(players[m].x1 + 3 * 5, players[m].y1 - 5 * 5, players[m].x1 + 5 * 6, players[m].y1 - 2 * 5);  //башня


                case players[m].poloschenie_tanka  of
                   1: Rectangle(players[m].x1 + 4 * 5, players[m].y1 - 9 * 5, players[m].x1 + 5 * 5 , players[m].y1 - (5 * 5) + 1);
                   2: Rectangle(players[m].x1 + 4 * 5, players[m].y1 - (2 * 5) - 1, players[m].x1 + 5 * 5 , players[m].y1 + 2 * 5);
                   3: Rectangle(players[m].x1 + (6 * 5) - 1, players[m].y1 - 4 * 5, players[m].x1 + 10 * 5, players[m].y1 - 3 * 5);
                   4: Rectangle(players[m].x1 - (2 * 5), players[m].y1 - 4 * 5, players[m].x1 + (3 * 5) + 1, players[m].y1 - 3 * 5);
                end;


                case players[m].poloschenie_tanka  of
                    1: begin //вперёд
                        Brush.Color := clBlack;
                        Rectangle(players[m].x1 + 1 * 5, players[m].y1 - 7 * 5, players[m].x1 + 2 * 5, players[m].y1);
                        Rectangle(players[m].x1 + 7 * 5, players[m].y1 - 7 * 5, players[m].x1 + 8 * 5, players[m].y1);
                    end;

                    2: begin   //назад
                        Brush.Color := clBlack;
                        Rectangle(players[m].x1 + 1 * 5, players[m].y1 - 7 * 5, players[m].x1 + 2 * 5, players[m].y1);
                        Rectangle(players[m].x1 + 7 * 5, players[m].y1 - 7 * 5, players[m].x1 + 8 * 5, players[m].y1);
                    end;

                    3: begin    //право
                        Brush.Color := clBlack;
                        Rectangle(players[m].x1 + 8 * 5, players[m].y1 - 1 * 5, players[m].x1 + 1 * 5, players[m].y1);     //нижняя
                        Rectangle(players[m].x1 + 8 * 5, players[m].y1 - 7 * 5, players[m].x1 + 1 * 5, players[m].y1 - 6 * 5);   //верхняя
                    end;

                    4: begin   //лево
                        Brush.Color := clBlack;
                        Rectangle(players[m].x1 + 1 * 5, players[m].y1 - 1 * 5, players[m].x1 + 8 * 5, players[m].y1);  //нижняя  гусля
                        Rectangle(players[m].x1 + 1 * 5, players[m].y1 - 7 * 5, players[m].x1 + 8 * 5, players[m].y1 - 6 * 5);  //верхняя гусля
                    end;
                end;
            end;
        end;
    end;
end;


//выход из настроек в игру с одним игроком
procedure TForm3.Button1Click(Sender: TObject);
begin
    sozdano_igrokov := 1;
    level := 1;
    New_Level();
    players[1].x1 := Form3.BackScreen.Width div 2;
    players[1].y1 := Form3.Height - 50;
    Settings_on := False;
end;

//выход из настроек в игру с двумя игроками
procedure TForm3.Button2Click(Sender: TObject);
begin
    sozdano_igrokov := 2;
    level := 1;
    New_Level();

    players[1].x1 := 0 + 150;
    players[1].y1 := Form3.Height - 50;

    players[2].x1 := Form3.BackScreen.Width - 150;
    players[2].y1 := Form3.Height - 50;
    Settings_on := False;
end;

//очищение edit1 при нажатии
procedure TForm3.Edit_Settings_1Click(Sender: TObject);
begin
      Edit_Settings_1.clear;
end;

//очищение edit2 при нажатии
procedure TForm3.Edit_Settings_2Click(Sender: TObject);
begin
    Edit_Settings_2.Clear;
end;

procedure TForm3.Edit_Settings_1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
 // var t: byte;
begin
    case key of
        81: first_player_shot_key := 81; //q
        87: first_player_shot_key := 87; //w
        69: first_player_shot_key := 69; //e
        82: first_player_shot_key := 82; //r
        84: first_player_shot_key := 84; //t
        89: first_player_shot_key := 89; //y
        85: first_player_shot_key := 85; //u
        73: first_player_shot_key := 73; //i
        79: first_player_shot_key := 79; //o
        80: first_player_shot_key := 80; //p
        219: first_player_shot_key := 219; //[
        221: first_player_shot_key := 221; //]
        65: first_player_shot_key := 65; //a
        83: first_player_shot_key := 83; //s
        68: first_player_shot_key := 68; //d
        70: first_player_shot_key := 70; //f
        71: first_player_shot_key := 71; //g
        72: first_player_shot_key := 72; //h
        74: first_player_shot_key := 74; //j
        75: first_player_shot_key := 75; //k
        76: first_player_shot_key := 76; //l
        186: first_player_shot_key := 186; //;
        222: first_player_shot_key := 222; //'
        220: first_player_shot_key := 220; //\
        90: first_player_shot_key := 90; //z
        88: first_player_shot_key := 88; //x
        67: first_player_shot_key := 67; //c
        86: first_player_shot_key := 86; //v
        66: first_player_shot_key := 66; //b
        78: first_player_shot_key := 78; //n
        77: first_player_shot_key := 77; //m
        188: first_player_shot_key := 188; //,
        190: first_player_shot_key := 190; //.
        191: first_player_shot_key := 191; // клавиша после "ю"
        192: first_player_shot_key := 192; //ё

        //цифры
        49: first_player_shot_key := 49; //1
        50: first_player_shot_key := 50; //2
        51: first_player_shot_key := 51; //3
        52: first_player_shot_key := 52; //4
        53: first_player_shot_key := 53; //5
        54: first_player_shot_key := 54; //6
        55: first_player_shot_key := 55; //7
        56: first_player_shot_key := 56; //8
        57: first_player_shot_key := 57; //9
        48: first_player_shot_key := 48; //0

        //numpad
        97: first_player_shot_key := 97; //1
        98: first_player_shot_key := 98; //2
        99: first_player_shot_key := 99; //3
        100: first_player_shot_key := 100; //4
        101: first_player_shot_key := 101; //5
        102: first_player_shot_key := 102; //6
        103: first_player_shot_key := 103; //7
        104: first_player_shot_key := 104; //8
        105: first_player_shot_key := 105; //9
        96: first_player_shot_key := 96; //0

        //стрелки
        37: //лево
            begin
                Form3.Edit_Settings_1.Text := '?';
                first_player_shot_key := 37;
            end;
        38: //вверх
            begin
                Form3.Edit_Settings_1.Text := '?';
                first_player_shot_key := 38;
            end;
        39: //право
            begin
                Form3.Edit_Settings_1.Text := '?';
                first_player_shot_key := 39;
            end;
        40: //вниз
            begin
                Form3.Edit_Settings_1.Text := '?';
                first_player_shot_key := 40;
            end;

        //CTRL, ALT, WIN, SPACE
        17:
            begin
                Form3.Edit_Settings_1.Text := 'CTRL';
                first_player_shot_key := 17;
            end;

         18:
            begin
                Form3.Edit_Settings_1.Text := 'ALT';
                first_player_shot_key := 18;
            end;

          91:
            begin
                Form3.Edit_Settings_1.Text := 'WIN';
                first_player_shot_key := 91;
            end;

          32:
            begin
                Form3.Edit_Settings_1.Text := 'SPACE';
                first_player_shot_key := 32;
            end;
    end;
end;

procedure TForm3.Edit_Settings_2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var t: byte;
begin
    case key of
        81: second_player_shot_key := 81; //q
        87: second_player_shot_key := 87; //w
        69: second_player_shot_key := 69; //e
        82: second_player_shot_key := 82; //r
        84: second_player_shot_key := 84; //t
        89: second_player_shot_key := 89; //y
        85: second_player_shot_key := 85; //u
        73: second_player_shot_key := 73; //i
        79: second_player_shot_key := 79; //o
        80: second_player_shot_key := 80; //p
        219: second_player_shot_key := 219; //[
        221: second_player_shot_key := 221; //]
        65: second_player_shot_key := 65; //a
        83: second_player_shot_key := 83; //s
        68: second_player_shot_key := 68; //d
        70: second_player_shot_key := 70; //f
        71: second_player_shot_key := 71; //g
        72: second_player_shot_key := 72; //h
        74: second_player_shot_key := 74; //j
        75: second_player_shot_key := 75; //k
        76: second_player_shot_key := 76; //l
        186: second_player_shot_key := 186; //;
        222: second_player_shot_key := 222; //'
        220: second_player_shot_key := 220; //\
        90: second_player_shot_key := 90; //z
        88: second_player_shot_key := 88; //x
        67: second_player_shot_key := 67; //c
        86: second_player_shot_key := 86; //v
        66: second_player_shot_key := 66; //b
        78: second_player_shot_key := 78; //n
        77: second_player_shot_key := 77; //m
        188: second_player_shot_key := 188; //,
        190: second_player_shot_key := 190; //.
        191: second_player_shot_key := 191; // клавиша после "ю"
        192: second_player_shot_key := 192; //ё

        //цифры
        49: second_player_shot_key := 49; //1
        50: second_player_shot_key := 50; //2
        51: second_player_shot_key := 51; //3
        52: second_player_shot_key := 52; //4
        53: second_player_shot_key := 53; //5
        54: second_player_shot_key := 54; //6
        55: second_player_shot_key := 55; //7
        56: second_player_shot_key := 56; //8
        57: second_player_shot_key := 57; //9
        48: second_player_shot_key := 48; //0

        //numpad
        97: second_player_shot_key := 97; //1
        98: second_player_shot_key := 98; //2
        99: second_player_shot_key := 99; //3
        100: second_player_shot_key := 100; //4
        101: second_player_shot_key := 101; //5
        102: second_player_shot_key := 102; //6
        103: second_player_shot_key := 103; //7
        104: second_player_shot_key := 104; //8
        105: second_player_shot_key := 105; //9
        96: second_player_shot_key := 96; //0

        //стрелки
        37: //лево
            begin
                Form3.Edit_Settings_2.Text := '?';
                second_player_shot_key := 37;
            end;
        38: //вверх
            begin
                Form3.Edit_Settings_2.Text := '?';
                second_player_shot_key := 38;
            end;
        39: //право
            begin
                Form3.Edit_Settings_2.Text := '?';
                second_player_shot_key := 39;
            end;
        40: //вниз
            begin
                Form3.Edit_Settings_2.Text := '?';
                second_player_shot_key := 40;
            end;

        //CTRL, ALT, WIN
        17:
            begin
                Form3.Edit_Settings_2.Text := 'CTRL';
                second_player_shot_key := 17;
            end;

         18:
            begin
                Form3.Edit_Settings_2.Text := 'ALT';
                second_player_shot_key := 18;
            end;

          91:
            begin
                Form3.Edit_Settings_2.Text := 'WIN';
                second_player_shot_key := 91;
            end;

          32:
            begin
                Form3.Edit_Settings_2.Text := 'SPACE';
                first_player_shot_key := 32;
            end;
    end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin

  level := 0;
  players[1].height := 35;
  players[1].width := 35;
  if sozdano_igrokov = 2 then
      players[2].height := 35;
      players[2].width := 35;
  Timer1.Interval := 50;
  randomize;
  first_player_shot_key := 32;
  second_player_shot_key := 17;
//  Form3.Timer1.Enabled := True;
//  skorost_pt_sau := 3;
//  skorost_legkogo_tanka := 5;
//  skorost_srednego_tanka := 4;

  Form3.Timer1.Enabled := False;
  New_Level();
end;

procedure Sozdanie_puli(number_of_gamer: byte);
var p: byte;
begin
     for p := 1 to 100 do
      if not puli[p].enabled then
        begin
          //присвоение начальных значений координат снаряда
          puli[p].enabled := True;
          case players[number_of_gamer].poloschenie_tanka of
          1:
            begin
                puli[p].napravlenie := 1;
                puli[p].x1 := players[number_of_gamer].x1 + 35 div 2 + 3;//3 - половина ширины снаряда, 35 - ширина танка
                puli[p].x2 := puli[p].x1 + 6;// 6 ширина снаряда
                puli[p].y1 := players[number_of_gamer].y1 - 35 - 11;//18 - высота снаряда
                puli[p].y2 := players[number_of_gamer].y1 - 35;
            end;

          2:
            begin
                puli[p].napravlenie := 2;
                puli[p].x1 := players[number_of_gamer].x1 + 35 div 2 + 3;//3 - половина ширины снаряда, 35 - ширина танка
                puli[p].x2 := puli[p].x1 + 6;// 6 ширина снаряда
                puli[p].y1 := players[number_of_gamer].y1 + 2 * 5;//11 - высота снаряда
                puli[p].y2 := players[number_of_gamer].y1 + 2 * 5 + 11;
            end;
          3:     //право
            begin
                puli[p].napravlenie := 3;
                puli[p].x1 := players[number_of_gamer].x1 + 9 * 5;//3 - половина ширины снаряда, 35 - ширина танка
                puli[p].x2 := puli[p].x1 + 11;// 6 ширина снаряда
                puli[p].y1 := players[number_of_gamer].y1 - 4 * 5;//18 - высота снаряда
                puli[p].y2 := players[number_of_gamer].y1 - (3 * 5) - 1;
            end;

          4:   //лево
            begin
                puli[p].napravlenie := 4;
                puli[p].x1 := players[number_of_gamer].x1 - 2 * 5 - 11;//3 - половина ширины снаряда, 35 - ширина танка
                puli[p].x2 := puli[p].x1 + 11;// 6 ширина снаряда
                puli[p].y1 := players[number_of_gamer].y1 - 4 * 5;//18 - высота снаряда
                puli[p].y2 := players[number_of_gamer].y1 - (3 * 5) - 1;
            end;
          end;
          players[number_of_gamer].perzaryaschen := False;
          sdelano_vistrelov := sdelano_vistrelov + 1;
          Statistika();
          break;
        end;
     Proverka();
end;

procedure Igra_v_zastavke();
var q: byte;
begin
        if not zapuskalsya then
            begin
                rasstoyanie_do_blishaishego_vraga := 100000;
                zapuskalsya := True;
            end;
        for q := 1 to vragi_count do
            if vragi[q].health > 0 then
                if (abs((vragi[q].y2 - players[1].y1)) < rasstoyanie_do_blishaishego_vraga) and (vragi[q].y2 < players[1].y1) and (nomer_blishaishego_vraga <> q) Then
                    begin
                        nomer_blishaishego_vraga := q;
                        rasstoyanie_do_blishaishego_vraga := vragi[q].y2 - players[1].y1;
                        blischaischi_vrag_izmenilsya := True;
                        predpologaemoe_health := vragi[q].health;
                    end;




                if vragi[nomer_blishaishego_vraga].x1 < players[1].x1 then
                    nushnoe_napravlenie := 4;//лево

                if vragi[nomer_blishaishego_vraga].x1 > players[1].x1 then
                    nushnoe_napravlenie := 3;//право

//                 if (vragi[nomer_blishaishego_vraga].x1 <= (players[1].x1 + (players[1].width div 2))) or (vragi[nomer_blishaishego_vraga].x2 >= (players[1].x1 + (players[1].width div 2))) then
//                    nushnoe_napravlenie := 1;//вверх

                if players[1].poloschenie_tanka <> nushnoe_napravlenie then
                    players[1].poloschenie_tanka := nushnoe_napravlenie;



                if sozdano_vragov > 0 then
                    begin
                        if blischaischi_vrag_izmenilsya then
                        begin
                            vremya_do_vstreshi :=  abs(trunc(rasstoyanie_do_blishaishego_vraga / vragi[nomer_blishaishego_vraga].skorost));

                            if players[1].poloschenie_tanka = 3 then
                                vremya_poleta_snaryada := abs(trunc((vragi[nomer_blishaishego_vraga].x1 - players[1].x1) / skorost_snaryada));
                            if players[1].poloschenie_tanka = 4 then
                                vremya_poleta_snaryada := abs(trunc((vragi[nomer_blishaishego_vraga].x2 - players[1].x1) / skorost_snaryada));

                            if vremya_poleta_snaryada = 0 then
                                vremya_poleta_snaryada := 1;

                            vremya_do_vistrela := abs(vremya_do_vstreshi - vremya_poleta_snaryada);
                            blischaischi_vrag_izmenilsya := False;
                        end;


                            if vremya_do_vistrela = 0 then
                            begin
                                if players[1].perzaryaschen then
                                    begin
                                    Sozdanie_puli(1);
                                    predpologaemoe_health := predpologaemoe_health - 1;
                                    if predpologaemoe_health = 0 then
                                        vremya_do_vistrela := -1;
                                    end;
                            end
                            else vremya_do_vistrela := vremya_do_vistrela - 1;


                               if (vragi[nomer_blishaishego_vraga].y1 > (players[1].y1 + players[1].width div 2)) and (predpologaemoe_health > 0) then
                                begin
                                    vremya_do_vistrela := -1;
                                    blischaischi_vrag_izmenilsya := True;
                                end;
                    end;


end;

procedure obrabotka_naschatih_klavish ();
var e, raznica_x, rasstoyanie, raznica_y: integer;
    naezd_x, naezd_y, naezd: boolean;
begin
    if level <> 0 then
    begin
      if (getasynckeystate(first_player_shot_key) <> 0) Then   //пробел
       begin
           if (players[1].perzaryaschen) and (level <> 0) Then //space
           begin
                  Sozdanie_puli(1);
           end;
       end;


       if (getasynckeystate(107) <> 0) Then players[1].speed := players[1].speed + 2; //+

       if (getasynckeystate(109) <> 0) Then players[1].speed := players[1].speed - 2;  //-

       if (getasynckeystate(80) <> 0) Then //Пауза
       begin
            if Form3.Timer1.Enabled then
              begin
                   Form3.Timer1.Enabled := False;
                   Form3.Canvas.Font.Size := 34;
                   Form3.Canvas.Font.Color := clWhite;
                   Form3.Canvas.Brush.Style := bsClear;
                   Form3.Canvas.TextOut(tekst_x, tekst_y, 'Пауза'); //сделать переменные
              end
            else
                  Form3.Timer1.Enabled := True;
       end;



        if(getasynckeystate(87) <> 0) Then  //ц, Ц, w, W - вверх
        begin
            if players[1].poloschenie_tanka <> 1 then
              players[1].poloschenie_tanka := 1
            else
              begin
                if (players[1].y1 - players[1].height) >= players[1].speed Then
                    begin
//                        for e := 1 to vragi_count do
//                        begin
//                            raznica_y := abs(vragi[e].y2 - players[1].y1);
//                            if raznica_y > (abs(vragi[e].y1 - players[1].y1)) then
//                                raznica_y := abs(vragi[e].y1 - players[1].y1);
//
//                            naezd_x := (((players[1].x1 <= vragi[e].x1) and (vragi[e].x1 <= players[1].x2)) or ((players[1].x1 <= vragi[e].x2) and (vragi[e].x2 <= players[1].x2)));
//                            naezd_y := raznica_y <= players[1].speed;
//                            naezd := naezd_x and naezd_y;
//
//                            if naezd then
//                            begin
//                                players[1].y1 := players[1].y1 - raznica_y;
//                                Break;
//                            end;
//                        end;
//
//                        if not naezd then
                            players[1].y1 := players[1].y1 - players[1].speed;
                    end;
              end;
        end;

        if(getasynckeystate(65) <> 0) Then//ф, Ф, a, A - влево
        begin
          if players[1].poloschenie_tanka <> 4 then
            begin
              players[1].poloschenie_tanka := 4
            end
          else
            begin
            if players[1].x1 >= players[1].speed  Then
              begin
                  for e := 1 to vragi_count do
                      begin
                          raznica_x := abs(players[1].x1 - vragi[e].x2);
                          naezd_x := raznica_x <= players[1].speed;
                          naezd_y := (((players[1].y2 <= vragi[e].y1) and (vragi[e].y1 <= players[1].y1)) or ((players[1].y2 <= vragi[e].y2) and (vragi[e].y2 <= players[1].y1)));
                          if (naezd_x) and (naezd_y) and (vragi[e].health > 0)  then
                              begin
                                  players[1].x1 := players[1].x1 - raznica_x;
                                  break;
                              end
                      end;
                  if not naezd_x and not naezd_y then
                      players[1].x1 := players[1].x1 - players[1].speed;

              end;
              naezd_x := False;
              naezd_y := False;
            end;
        end;

        if (getasynckeystate(83) <> 0) Then//S, s, ы, Ы - вниз
        begin
            if players[1].poloschenie_tanka <> 2 then
                players[1].poloschenie_tanka := 2
            else
                begin
                  if (players[1].y1 + players[1].height + players[1].speed)  <= Form3.Height Then
                    players[1].y1 := players[1].y1 + players[1].speed;
                end;

         end;

        if (getasynckeystate(68) <> 0) Then//в, В, d, D - вправо
        begin
            if players[1].poloschenie_tanka <> 3 then    //вправо
                players[1].poloschenie_tanka := 3
            else
              begin
              if (players[1].x1 + players[1].width) < (Form3.BackScreen.Width - 140)  Then
                  begin
                      for e := 1 to vragi_count do
                          begin
                              raznica_x := abs(vragi[e].x1 - players[1].x2);
                              naezd_x := raznica_x <= players[1].speed;
                              naezd_y := (((players[1].y2 <= vragi[e].y1) and (vragi[e].y1 <= players[1].y1)) or ((players[1].y2 <= vragi[e].y2) and (vragi[e].y2 <= players[1].y1)));
                              if (naezd_x) and (naezd_y) and (vragi[e].health > 0) then
                                  begin
                                      players[1].x1 := players[1].x1 + raznica_x;
                                      break;
                                  end
                          end;
                      if (not naezd_x and not naezd_y) or (not naezd_x and naezd_y) or (naezd_x and not naezd_y) then
                          players[1].x1 := players[1].x1 + players[1].speed;

                  end;
              if (players[1].x1 + players[1].width) >= (Form3.BackScreen.Width - 140)  Then
                  begin
                      rasstoyanie := (Form3.BackScreen.Width - 140) - (players[1].x1 + players[1].width);
                      players[1].x1 := players[1].x1 + rasstoyanie;
                  end;

              end;
        end;

       if (getasynckeystate(second_player_shot_key) <> 0) Then //CTRL
        begin
          if (players[2].perzaryaschen) and (level <> 0) Then
                  begin
                      players[2].perzaryaschen := False;
                      Sozdanie_puli(2);
                  end;
        end;


        if (getasynckeystate(38) <> 0) Then  //стрелка вверх
          begin
                if players[2].poloschenie_tanka <> 1 then
                  players[2].poloschenie_tanka := 1
                else
                  begin
                        if (players[2].y1 - players[2].height) >= players[2].speed Then
                            begin
                                   players[2].y1 := players[2].y1 - players[2].speed;
                                   for e := 1 to vragi_count do
                                      begin
                                          raznica_y := abs(vragi[e].y2 - players[2].y1);
                                          if raznica_y > (abs(vragi[e].y1 - players[2].y1)) then
                                             raznica_y := abs(vragi[e].y1 - players[2].y1);

                                          naezd_x := ((players[2].y2 <= vragi[e].y1) and (vragi[e].y1 <= players[2].y1)) or ((players[2].y2 <= vragi[e].y2) and (vragi[e].y2 <= players[2].y1));
                                          naezd_y := raznica_y <= players[2].speed;
                                          naezd := naezd_x and naezd_y;

                                          if naezd then
                                              begin
                                                  players[2].y1 := players[2].y1 - raznica_y;
                                                  Break;
                                              end;
                                      end;
//                                   if not naezd then
//                                      begin
//                                          raznica_y := abs(players[1].y2 - players[2].y1);
//                                          if raznica_y > (abs(players[1].y1 - players[2].y1)) then
//                                             raznica_y := abs(players[1].y1 - players[2].y1);
//
//                                          naezd := naezd_x and naezd_y;
//                                      end;

                            end
                        else players[2].y1 := players[2].y1 - (players[2].y1 - players[2].height);
                  end;
          end;


        if (getasynckeystate(40) <> 0) Then//стрелка вниз
          begin
                if players[2].poloschenie_tanka <> 2 then
                    players[2].poloschenie_tanka := 2
                else
                    begin
                      if (players[2].y1 + players[2].height + players[2].speed)  <= Form3.Height Then
                        players[2].y1 := players[2].y1 + players[2].speed;
                    end;

           end;

        if (getasynckeystate(39) <> 0) Then//стрелка направо
          begin
                if players[2].poloschenie_tanka <> 3 then    //вправо
                players[2].poloschenie_tanka := 3
            else
              begin
              if (players[2].x1 + players[2].width) < (Form3.BackScreen.Width - 140)  Then
                  begin
                      for e := 1 to vragi_count do
                          begin
                              raznica_x := abs(vragi[e].x1 - players[2].x2);
                              naezd_x := raznica_x <= players[2].speed;
                              naezd_y := (((players[2].y2 <= vragi[e].y1) and (vragi[e].y1 <= players[2].y1)) or ((players[2].y2 <= vragi[e].y2) and (vragi[e].y2 <= players[2].y1)));
                              if (naezd_x) and (naezd_y) and (vragi[e].health > 0) then
                                  begin
                                      players[2].x1 := players[2].x1 + raznica_x;
                                      break;
                                  end
                          end;
                      if (not naezd_x and not naezd_y) or (not naezd_x and naezd_y) or (naezd_x and not naezd_y) then
                          players[2].x1 := players[2].x1 + players[2].speed;

                  end;
                  naezd_x := False;
                  naezd_y := False;
                  if (players[2].x1 + players[2].width) >= (Form3.BackScreen.Width - 140)  Then
                  begin
                      rasstoyanie := (Form3.BackScreen.Width - 140) - (players[2].x1 + players[2].width);
                      players[2].x1 := players[2].x1 + rasstoyanie;
                  end;
              end;
          end;

        if (getasynckeystate(37) <> 0) Then//стрелка налево
          begin
               if players[2].poloschenie_tanka <> 4 then
                begin
                    players[2].poloschenie_tanka := 4
                end
              else
                begin
                    if players[2].x1 >= players[2].speed  Then
                        begin
                            for e := 1 to vragi_count do
                                begin
                                    raznica_x := abs(players[2].x1 - vragi[e].x2);
                                    naezd_x := raznica_x <= players[2].speed;
                                    naezd_y := (((players[2].y2 <= vragi[e].y1) and (vragi[e].y1 <= players[2].y1)) or ((players[2].y2 <= vragi[e].y2) and (vragi[e].y2 <= players[2].y1)));
                                    if (naezd_x) and (naezd_y) and (vragi[e].health > 0) then
                                        begin
                                            players[2].x1 := players[2].x1 - raznica_x;
                                            break;
                                        end
                                end;
                            if not naezd_x and not naezd_y then
                                players[2].x1 := players[2].x1 - players[2].speed;

                        end;
                      naezd_x := False;
                      naezd_y := False;
                end;
          end;
    end
    else
        begin

           if (getasynckeystate(97) <> 0) or (GetAsyncKeyState(49) <> 0) Then //1
           begin
                sozdano_igrokov := 1;
                level := 1;
                New_Level();
                players[1].x1 := Form3.BackScreen.Width div 2;
                players[1].y1 := Form3.Height - 50;
                Settings_on := False;
           end;


           if (getasynckeystate(98) <> 0) or (getasynckeystate(50) <> 0) Then  //2
           begin
              sozdano_igrokov := 2;
              level := 1;
              New_Level();

              players[1].x1 := 0 + 150;
              players[1].y1 := Form3.Height - 50;

              players[2].x1 := Form3.BackScreen.Width - 150;
              players[2].y1 := Form3.Height - 50;
              Settings_on := False;
           end;

           if (getasynckeystate(99) <> 0) or (getasynckeystate(51) <> 0) then  //3, вызывается окно с настройками
              begin
                  Settings;
              end;
        end;



end;

procedure Drawing ();   //процедура рисования танка, снаряда(снарядов), взрыва(взрывов), врагов
var j, vzriv_x, vzriv_y, i: integer;
    v, r: byte;
    raznica_y: integer;
    popadanie_x, popadanie_y, naezd_x, naezd_y, naezd: boolean;

    raznica_d1, raznica_d2, raznica_d3, raznica_d4: integer;
  begin
      if (level = 0) and not Settings_on then
          Igra_v_zastavke();
          obrabotka_naschatih_klavish ();

      Statistika();
      if not schitano then
          begin
              schitivanie_s_file();
              schitano := True;
          end;

      for r := 1 to sozdano_igrokov do
          if not players[r].perzaryaschen then
              begin
                  if players[r].perezaryadka = perezaryadka_player then
                      begin
                          players[r].perzaryaschen := True;
                          players[r].perezaryadka := 0;
                      end
                  else  players[r].perezaryadka := players[r].perezaryadka + 1;
              end;


      //добавляю врага каждые chastota_poyavlenya тактов работы таймера
      if takt = 0 then Create_Enemy();
          takt := takt + 1;
      if takt = chastota_poyavlenya then takt := 0;

      with Form3.BackScreen.Canvas do
          begin
          CopyRect(Rect(0,0,Screen.Width, Screen.Height), Form3.BackGround.Canvas, Rect(0,0,Screen.Width, Screen.Height));

          if not Settings_on then
            begin
              //отрисовка статистики
              if not Form3.Statistika1.Visible then
                  begin
                       Form3.Button1.Visible := False;
                       Form3.Button2.Visible := False;


                       Form3.Edit_Settings_1.Visible := False;
                       Form3.Edit_Settings_2.Visible := False;

                       Form3.Lable_Settings_1.Visible := False;
                       Form3.Lable_Settings_2.Visible := False;



                      Form3.Statistika1.Visible := True;
                      Form3.Statistika2.Visible := True;
                      Form3.Statistika3.Visible := True;
                      Form3.Statistika4.Visible := True;
                  end;

              Form3.BackGround.Canvas.Draw(nachalinie_koordinati_statistiki_x, nachalinie_koordinati_statistiki_y, Form3.Vragov_ostalos.Picture.Bitmap);
              Form3.BackGround.Canvas.Draw(nachalinie_koordinati_statistiki_x, nachalinie_koordinati_statistiki_y + 70, Form3.snaryadov_ostalos.Picture.Bitmap);
              Form3.BackGround.Canvas.Draw(nachalinie_koordinati_statistiki_x, nachalinie_koordinati_statistiki_y + 2 * 70, Form3.Image1.Picture.Bitmap);

                //отрисовка своего танка
                  for r := 1 to sozdano_igrokov do
                    Risovanie_Tanka(players[r].x1, players[r].y1, 1, False);


              //отрисовка врагов
              for i := 1 to 20 do
                if vragi[i].health > 0 then
                  begin
    //                for r := 1 to sozdano_igrokov do
    //                    begin
    //                         raznica_y := abs(vragi[i].y2 - players[r].y1);
    //                        if (raznica_y > abs(vragi[i].y2 - players[r].y2)) and (players[r].y2 <> 0) then
    //                            raznica_y := abs(vragi[i].y2 - players[r].y2);
    //
    //                        naezd_x := (((players[r].x1 <= vragi[i].x1) and (vragi[i].x1 <= players[r].x2)) or ((players[r].x1 <= vragi[i].x2) and (vragi[i].x2 <= players[r].x2)));
    //                        naezd_y := raznica_y < vragi[i].skorost;
    //                        naezd := naezd_x and naezd_y;
    //
    //                        if naezd then
    //                            begin
    //                                vragi[i].y1 := vragi[i].y1 + raznica_y;
    //                                vragi[i].y2 := vragi[i].y2 + raznica_y;
    //                                break
    //                            end;
    //
    //                    end;
    //
    //                if not naezd then
    //                    begin
                            vragi[i].y1 := vragi[i].y1 + vragi[i].skorost;
                            vragi[i].y2 := vragi[i].y2 + vragi[i].skorost;
                    //    end;

                    if vragi[i].y1 > Form3.Screen.Height then
                      begin
                        vragi[i].health := 0;
                        vragi[i].proehal := True;
                        vragov_propuscheno := vragov_propuscheno + 1;
                        vragi[i].perezaryadka := 0;
                        Statistika();
                      end
                    else
                      begin
                          Risovanie_Tanka(vragi[i].x1, vragi[i].y2, vragi[i].type_of_tank, True);
                      end;
                   end;

              //отрисовка снарядов
              for i := 1 to 100 do
                begin
                if puli[i].enabled then
                  begin
                    case puli[i].napravlenie of
                      1:
                      begin
                          puli[i].y2 :=  puli[i].y2 - skorost_snaryada;//10 - скорость движения снарядов
                          puli[i].y1 :=  puli[i].y1 - skorost_snaryada;//10 - скорость движения снарядов
                      end;
                      2:
                      begin
                          puli[i].y1 :=  puli[i].y1 + skorost_snaryada;//10 - скорость движения снарядов
                          puli[i].y2 :=  puli[i].y2 + skorost_snaryada;//10 - скорость движения снарядов
                      end;
                      3:
                      begin
                          puli[i].x1 :=  puli[i].x1 + skorost_snaryada;//10 - скорость движения снарядов
                          puli[i].x2 :=  puli[i].x2 + skorost_snaryada;//10 - скорость движения снарядов
                      end;

                      4:
                      begin
                          puli[i].x2 :=  puli[i].x2 - skorost_snaryada;//10 - скорость движения снарядов
                          puli[i].x1 :=  puli[i].x1 - skorost_snaryada;//10 - скорость движения снарядов
                      end;
                    end;

                    if (puli[i].y2 <= 0) or (puli[i].y2 >= Form3.Height) or ((puli[i].x1 + 2) <= 0) or ((puli[i].x1 + 2) >= Form3.Width)  then
                      begin
                      puli[i].enabled := False; //снаряд вышел за границы, больше он не будет рисоваться
                      break;
                      end;

                    //проверка попадания снаряда в каждого из врагов
                    Popadanie_snaryada_igroka(i);



                    if puli[i].enabled then
                      begin
                         //процедура рисования пули
                         Risovanie_snaryda(False, i);
                      end;
                  end;
                end;
                      //создание снарядов врага
                      for r := 1 to sozdano_igrokov do                                //перебор танков игрока (игроков)
                          for i := 1 to 20 do
                          if (vragi[i].health > 0) and (level <> 0) then
                            begin
                                players[r].x2 := players[r].x1 + 7 * 5;
                                players[r].y2 := players[r].y1 - 7 * 5;

                                raznica_d1 := Abs(vragi[i].x1 - players[r].x1);
                                raznica_d2 := Abs(vragi[i].x2 - players[r].x2);

                                raznica_d3 := Abs(vragi[i].x1 - players[r].x2);
                                raznica_d4 := Abs(vragi[i].x2 - players[r].x1);

                                if (vragi[i].perezaryadka = 0) and (((raznica_d1 >= 0) and (raznica_d1 <= players[r].width)) or (((raznica_d2 >= 0) and (raznica_d2 <= players[r].width))) or (((raznica_d3 >= 0) and (raznica_d3 <= players[r].width))) or ((raznica_d4 >= 0) and (raznica_d4 <= players[r].width))) then
                                    begin
                                        vragi[i].perezaryadka := perezaryadka_tanka_vraga;
                                        Sozdanie_puli_vraga(i);
                                    end;

                                if vragi[i].perezaryadka <> 0 then
                                    vragi[i].perezaryadka := vragi[i].perezaryadka - 1;
                            end;



                     for i := 1 to puli_vraga_count do
                       if puli_vraga[i].enabled then
                        begin
                          puli_vraga[i].y1 :=  puli_vraga[i].y1 + skorost_snaryada;//10 - скорость движения снарядов
                          puli_vraga[i].y2 :=  puli_vraga[i].y2 + skorost_snaryada;//10 - скорость движения снарядов
                          if (puli_vraga[i].y2 <= 0) or (puli_vraga[i].y2 >= Form3.Height) or ((puli_vraga[i].x1 + 2) <= 0) or ((puli_vraga[i].x1 + 2) >= Form3.Width)  then

                              begin
                                  puli_vraga[i].enabled := False; //снаряд вышел за границы, больше он не будет рисоваться
                              end;
                        end;

                              Popadanie_snaryada_vraga();

                     //отрисовка снарядов врага
                      for i := 1 to puli_vraga_count do
                      begin
                        if puli_vraga[i].enabled then
                          begin
                                Risovanie_snaryda(True, i);
                          end;
                      end;

                //рисую взрыв
                for v := 1 to vzrivi_count do
                    if vzrivi[v].etap <> 0 then
                      begin
                          if vzrivi[v].enemy_number = 0 then
                            begin
                                vzriv_x := vzrivi[v].x;
                                vzriv_y := vzrivi[v].y;
                            end
                          else
                            begin
                                vzriv_x := vragi[vzrivi[v].enemy_number].x1 + vzrivi[v].x;
                                vzriv_y := vragi[vzrivi[v].enemy_number].y1 + vzrivi[v].y;
                            end;
                          case vzrivi[v].etap of
                            31..35 :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_1.Picture.Bitmap);
                            26..30 :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_2.Picture.Bitmap);
                            21..25 :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_3.Picture.Bitmap);
                            16..20 :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_4.Picture.Bitmap);
                            11..15 :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_3.Picture.Bitmap);
                            6..10  :  Draw(vzriv_x, vzriv_y, Form3.Image_implosion_2.Picture.Bitmap);
                            1..5  :   Draw(vzriv_x, vzriv_y, Form3.Image_implosion_1.Picture.Bitmap);
                          end;
                        vzrivi[v].etap := vzrivi[v].etap - 1;
                      end;

            end;
          end; // with Form3.BackScreen.Canvas do

      Form3.Screen.Canvas.CopyRect(Rect(0,0,Screen.Width, Screen.Height), Form3.BackScreen.Canvas, Rect(0,0,Screen.Width, Screen.Height));
      Proverka();

  end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Drawing();
end;

end.
