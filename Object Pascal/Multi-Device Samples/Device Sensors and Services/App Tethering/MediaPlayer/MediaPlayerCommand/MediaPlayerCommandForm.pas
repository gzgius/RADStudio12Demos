//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit MediaPlayerCommandForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, FMX.ListBox, IPPeerClient, IPPeerServer,
  System.Tether.Manager, System.Tether.AppProfile, FMX.Memo, FMX.Controls.Presentation, FMX.Edit, FMX.ComboEdit;

type
  TForm3 = class(TForm)
    CommandManager: TTetheringManager;
    CommandApp: TTetheringAppProfile;
    Button1: TButton;
    BFindPlayers: TButton;
    lbPlayers: TListBox;
    VolumeTrack: TTrackBar;
    Label2: TLabel;
    CBAdapter: TComboBox;
    LabelFind: TLabel;
    CbEditTarget: TComboEdit;
    LabelAdapter: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BFindPlayersClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CommandManagerRequestManagerPassword(const Sender: TObject; const RemoteIdentifier: string; var Password: string);
    procedure lbPlayersItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure VolumeTrackChange(Sender: TObject);
    procedure CommandManagerEndManagersDiscovery(const Sender: TObject; const RemoteManagers: TTetheringManagerInfoList);
    procedure CommandManagerEndProfilesDiscovery(const Sender: TObject; const RemoteProfiles: TTetheringProfileInfoList);
    procedure CommandManagerRemoteManagerShutdown(const Sender: TObject; const ManagerIdentifier: string);
    procedure CBAdapterChange(Sender: TObject);
    procedure CommandManagerNewManager(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
    procedure FormShow(Sender: TObject);
{$IFDEF ANDROID}
  private const
    LOCATION_PERMISSION = 'android.permission.ACCESS_FINE_LOCATION';
    BLUETOOTH_SCAN_PERMISSION = 'android.permission.BLUETOOTH_SCAN';
    BLUETOOTH_CONNECT_PERMISSION = 'android.permission.BLUETOOTH_CONNECT';
{$ENDIF}
  private const
    BluetoothItemIndex = 0;
  private type
    TBluetoothAvailability = (Unknown, Allowed, Prohibited);
  private
    FBluetoothAvailability: TBluetoothAvailability;
    FInvariantFormatSettings: TFormatSettings;
    function CheckMediaPlayers: Boolean;
    procedure RefreshList;
    function CheckBluetoothAvailability: Boolean;
    function StartCommandManager: Boolean;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses
  System.Permissions;

{$R *.fmx}

procedure TForm3.Button1Click(Sender: TObject);
begin
  if CheckMediaPlayers then
    CommandApp.RunRemoteAction(CommandManager.RemoteProfiles[LbPlayers.ItemIndex], 'acPlayPause');
end;

procedure TForm3.BFindPlayersClick(Sender: TObject);
var
  I: Integer;
begin
  if not StartCommandManager then
    Exit;

  if CommandApp.Manager = nil then
    CommandApp.Manager := CommandManager;

  for I := CommandManager.PairedManagers.Count - 1 downto 0 do
    CommandManager.UnPairManager(CommandManager.PairedManagers[I]);
  LbPlayers.Items.Clear;
  lbPlayers.Items.Add('Finding Players ...');
  if CbEditTarget.ItemIndex <> -1 then
  begin
    CommandManager.DiscoverManagers(CbEditTarget.Items[CbEditTarget.ItemIndex]);
  end
  else if CbEditTarget.Text <> '' then
  begin
    CommandManager.DiscoverManagers(CbEditTarget.Text);
  end
  else
    CommandManager.DiscoverManagers;
end;

procedure TForm3.CBAdapterChange(Sender: TObject);
begin
  CommandManager.Enabled := False;
  CbEditTarget.Items.Clear;
  CbEditTarget.Items.Add('');
  CbEditTarget.ItemIndex := -1; // Select none
  if CBAdapter.ItemIndex = BluetoothItemIndex then
    CbEditTarget.Items.Add('5c:f3:70:61:15:c4')
  else
  begin
    CbEditTarget.Items.Add('192.168.1.0');
    CbEditTarget.Items.Add('TargetHost1;TargetHost2');
    CbEditTarget.Items.Add('192.168.1.123');
  end;
  StartCommandManager;
end;

function TForm3.CheckMediaPlayers: Boolean;
begin
  if (CommandManager.RemoteProfiles.Count > 0) and (LbPlayers.ItemIndex >= 0) then
    Result := True
  else
  begin
    Result := False;
    if (CommandManager.RemoteProfiles.Count > 0) then
      ShowMessage('Select a MediaPlayer from the list to connect, please');
  end;
end;

procedure TForm3.RefreshList;
var
  I: Integer;
  LStrConn: string;

  function GetConnections(const AConnections: TTetheringAllowedConnections): string;
  var
    LConnection: TTetheringAllowedConnection;
  begin
    Result := '[';
    for LConnection in AConnections do
    begin
      Result := Result + Format('"%s:%s;%s",', [LConnection.ProtocolType, LConnection.AdapterType, LConnection.Connection]);
    end;

    Result[High(Result)] := ']';
  end;
begin
  lbPlayers.Clear;
  for I := 0 to CommandManager.RemoteProfiles.Count - 1 do
    if CommandManager.RemoteProfiles[I].ProfileText = 'FMXMediaPlayer' then
    begin
      LStrConn := GetConnections(CommandManager.RemoteProfiles[I].AllowedConnections);
      LbPlayers.Items.Add(CommandManager.RemoteProfiles[I].ProfileText+LStrConn);
    end;
  if LbPlayers.Count > 0 then
  begin
    // Connect to the first one
    if (LbPlayers.ItemIndex = -1) or (LbPlayers.ItemIndex >= lbPlayers.Count) then
      LbPlayers.ItemIndex := 0;
    CommandApp.Connect(CommandManager.RemoteProfiles[LbPlayers.ItemIndex]);
  end
  else
    lbPlayers.Items.Add('No Players Found');
end;

function TForm3.CheckBluetoothAvailability: Boolean;
{$IFDEF ANDROID}
const
  BluetoothDeniedMessage = 
    '''
    To use Bluetooth features in app you have to obtain permissions.

    To manage permissions manually, go to "Security & Privacy" -> "Privacy" -> "Permission manager"
    ''';

var
  Permissions: TArray<string>;
begin
  if FBluetoothAvailability = TBluetoothAvailability.Unknown then
  begin
    if TOSVersion.Check(12) then
      Permissions := [LOCATION_PERMISSION, BLUETOOTH_SCAN_PERMISSION, BLUETOOTH_CONNECT_PERMISSION]
    else
      Permissions := [LOCATION_PERMISSION];

    PermissionsService.RequestPermissions(Permissions,
      procedure(const Permissions: TClassicStringDynArray; const GrantResults: TClassicPermissionStatusDynArray)
      begin
        FBluetoothAvailability := TBluetoothAvailability.Allowed;
        for var GrantResult in GrantResults do
          if GrantResult <> TPermissionStatus.Granted then
          begin
            FBluetoothAvailability := TBluetoothAvailability.Prohibited;
            ShowMessage(BluetoothDeniedMessage);
            Break;
          end;
        StartCommandManager;
      end);
  end;
  Result := FBluetoothAvailability = TBluetoothAvailability.Allowed;
end;
{$ELSE}
begin
  Result := True;
end;
{$ENDIF}

function TForm3.StartCommandManager: Boolean;
begin
  if CBAdapter.ItemIndex = BluetoothItemIndex then
    Result := CheckBluetoothAvailability
  else
    Result := True;

  if Result then
    CommandManager.AllowedAdapters := CBAdapter.Items[CBAdapter.ItemIndex];

  CommandManager.Enabled := Result;
end;

procedure TForm3.CommandManagerEndManagersDiscovery(const Sender: TObject; const RemoteManagers: TTetheringManagerInfoList);
var
  I: Integer;
begin
  if RemoteManagers.Count = 0 then
    RefreshList
  else
  begin
    lbPlayers.Items.Clear;
    lbPlayers.Items.Add('Pairing Players');
    for I := 0 to RemoteManagers.Count - 1 do
      if RemoteManagers[I].ManagerText = 'FMXManager' then
        CommandManager.PairManager(RemoteManagers[I]);
  end;
end;

procedure TForm3.CommandManagerEndProfilesDiscovery(const Sender: TObject; const RemoteProfiles: TTetheringProfileInfoList);
begin
  RefreshList;
end;

procedure TForm3.CommandManagerNewManager(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  if AManagerInfo.ManagerText = 'FMXManager' then
    CommandManager.PairManager(AManagerInfo);
end;

procedure TForm3.CommandManagerRemoteManagerShutdown(const Sender: TObject; const ManagerIdentifier: string);
begin
  RefreshList;
end;

procedure TForm3.CommandManagerRequestManagerPassword(const Sender: TObject; const RemoteIdentifier: string; var Password: string);
begin
  Password := '1234';
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  FInvariantFormatSettings := TFormatSettings.Create;
  FInvariantFormatSettings.DecimalSeparator := '.';
  FInvariantFormatSettings.ThousandSeparator := ',';
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  StartCommandManager;
end;

procedure TForm3.lbPlayersItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if CommandManager.RemoteProfiles.Count > 0 then
    CommandApp.Connect(CommandManager.RemoteProfiles[Item.Index]);
end;

procedure TForm3.VolumeTrackChange(Sender: TObject);
begin
  if CheckMediaPlayers then
    CommandApp.SendString(CommandManager.RemoteProfiles[LbPlayers.ItemIndex], 'VolumeTrack',
      VolumeTrack.Value.ToString(FInvariantFormatSettings));
end;

end.
