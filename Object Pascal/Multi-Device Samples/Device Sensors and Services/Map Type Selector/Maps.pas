//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit Maps;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Permissions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FMX.Maps;

type
  TForm1 = class(TForm)
    TopToolBar: TToolBar;
    BottomToolBar: TToolBar;
    Label1: TLabel;
    edLat: TEdit;
    edLong: TEdit;
    Button1: TButton;
    MapView1: TMapView;
    Panel1: TPanel;
    GridPanelLayout1: TGridPanelLayout;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    TrackBar1: TTrackBar;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MapView1MapClick(const Position: TMapCoordinate);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
{$IF Defined(ANDROID)}
  private const
    CoarseLocationPermission = 'android.permission.ACCESS_COARSE_LOCATION';
    FineLocationPermission = 'android.permission.ACCESS_FINE_LOCATION';
{$ENDIF}
  private
    { Private declarations }
{$IF Defined(ANDROID)}
    procedure DisplayRationale(Sender: TObject; const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
    procedure LocationPermissionRequestResult(Sender: TObject; const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
{$ENDIF}
    procedure SetMapViewOptions;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  FMX.DialogService;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IF Defined(ANDROID)}
  PermissionsService.RequestPermissions([CoarseLocationPermission, FineLocationPermission], LocationPermissionRequestResult, DisplayRationale);
{$ELSE}
  SetMapViewOptions;
{$ENDIF}
end;

{$IF Defined(ANDROID)}
// Optional rationale display routine to display permission requirement rationale to the user
procedure TForm1.DisplayRationale(Sender: TObject; const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
begin
  // Show an explanation to the user *asynchronously* - don't block this thread waiting for the user's response!
  // After the user sees the explanation, invoke the post-rationale routine to request the permissions
  TDialogService.ShowMessage('The app can show where you are on the map if you give it permission',
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc;
    end)
end;

procedure TForm1.LocationPermissionRequestResult(Sender: TObject; const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
begin
  // 2 permissions involved: ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION
  if (Length(AGrantResults) = 2) and ((AGrantResults[0] = TPermissionStatus.Granted) or (AGrantResults[1] = TPermissionStatus.Granted)) then
    SetMapViewOptions;
end;
{$ENDIF}

procedure TForm1.SetMapViewOptions;
begin
  MapView1.ControlOptions := MapView1.ControlOptions + [TMapControlOption.MyLocation];
  MapView1.LayerOptions := MapView1.LayerOptions + [TMapLayerOption.UserLocation];
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  MapCenter: TMapCoordinate;
begin
  MapCenter := TMapCoordinate.Create(StrToFloat(edLat.Text, TFormatSettings.Invariant), StrToFloat(edLong.Text, TFormatSettings.Invariant));
  MapView1.Location := MapCenter;
end;

procedure TForm1.MapView1MapClick(const Position: TMapCoordinate);
var
  MyMarker: TMapMarkerDescriptor;
begin
  MyMarker := TMapMarkerDescriptor.Create(Position, 'MyMarker');
  MyMarker.Draggable := True;
  MyMarker.Visible := True;
  MapView1.AddMarker(MyMarker);
end;

// -------------------For Normal button -----------------------------------------

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  MapView1.MapType := TMapType.Normal;
  TrackBar1.Value := 0.0;
end;

// -------------------For Satellite button---------------------------------------

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  MapView1.MapType := TMapType.Satellite;
  TrackBar1.Value := 0.0;
end;

// --------------------For Hybrid button-----------------------------------------

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  MapView1.MapType := TMapType.Hybrid;
  TrackBar1.Value := 0.0;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  MapView1.Bearing := TrackBar1.Value;
end;

end.
