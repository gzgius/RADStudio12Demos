//---------------------------------------------------------------------------

// This software is Copyright (c) 2022 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

#ifndef SampleFormImageH
#define SampleFormImageH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Forms.hpp>
#include "SampleFormBase.h"
#include <FMX.Skia.hpp>
#include <System.Skia.hpp>
#include <FMX.Controls.Presentation.hpp>
#include <FMX.Layouts.hpp>
#include <FMX.Objects.hpp>
#include <FMX.StdCtrls.hpp>
#include <FMX.Types.hpp>
//---------------------------------------------------------------------------

class TfrmImage : public TfrmBase
{
__published:
	TSpeedButton *btnEncodeWebpVsJpeg;
	TSkLabel *lblEncodeWebpVsJpegTitle;
	TSkLabel *lblEncodeWebpVsJpegDescription;
	TSpeedButton *btnNinePatch;
	TSkLabel *lblNinePatchTitle;
	TSkLabel *lblNinePatchDescription;
	TSpeedButton *btnWebpInImage;
	TSkLabel *lblWebpInImageTitle;
	TSkLabel *lblWebpInImageDescription;
	TLayout *lytContentTopOffset;
	void __fastcall btnEncodeWebpVsJpegClick(TObject* Sender);
	void __fastcall btnNinePatchClick(TObject* Sender);
	void __fastcall btnWebpInImageClick(TObject* Sender);
public:
	__fastcall TfrmImage(TComponent* Owner) override : TfrmBase(Owner) {}
};

#endif
