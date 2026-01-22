#include <wx/aboutdlg.h>
#include <wx/wx.h>

#if !defined(__WXMSW__)
#include "../graphics/appicon/appicon.xpm"
#endif

#include "licenses.h"

namespace {
enum
{
    ID_ShowLicenses = wxID_HIGHEST + 1
};

class MainFrame : public wxFrame {
public:
    MainFrame() : wxFrame(nullptr, wxID_ANY, "wxWidgets Hello World") {
        this->CreateMenus();
        this->CreateContent();
        this->ApplyIcon();
        this->Centre();
    }

private:
    void CreateMenus() {
        auto *menu_bar = new wxMenuBar;

        auto *file_menu = new wxMenu;
        file_menu->Append(wxID_EXIT, "E&xit\tCtrl-Q");
        menu_bar->Append(file_menu, "&File");

        auto *help_menu = new wxMenu;
        help_menu->Append(ID_ShowLicenses, "&Licenses");
        help_menu->Append(wxID_ABOUT);
        menu_bar->Append(help_menu, "&Help");

        this->SetMenuBar(menu_bar);

        this->Bind(wxEVT_MENU, &MainFrame::OnExit, this, wxID_EXIT);
        this->Bind(wxEVT_MENU, &MainFrame::OnShowLicenses, this, ID_ShowLicenses);
        this->Bind(wxEVT_MENU, &MainFrame::OnAbout, this, wxID_ABOUT);
    }

    void CreateContent() {
        auto *panel = new wxPanel(this);
        auto *sizer = new wxBoxSizer(wxVERTICAL);
        auto *label = new wxStaticText(panel, wxID_ANY, "Hello from wxWidgets!");

        sizer->AddStretchSpacer();
        sizer->Add(label, 0, wxALIGN_CENTER | wxALL, 20);
        sizer->AddStretchSpacer();
        panel->SetSizerAndFit(sizer);

        this->SetClientSize(panel->GetBestSize());
    }

    void ApplyIcon() {
#if defined(__WXMSW__)
        wxIcon icon("appicon", wxBITMAP_TYPE_ICO_RESOURCE, 32, 32);
#else
        wxIcon icon(appicon);
#endif
        if (icon.IsOk()) {
            this->SetIcon(icon);
        }
    }

    void OnExit(wxCommandEvent &event) {
        this->Close(true);
    }

    void OnShowLicenses(wxCommandEvent &event) {
        wxDialog dialog(
                this,
                wxID_ANY,
                "Licenses",
                wxDefaultPosition,
                wxSize(640, 480),
                wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER);

        auto *sizer = new wxBoxSizer(wxVERTICAL);
        auto *text = new wxTextCtrl(
                &dialog,
                wxID_ANY,
                wxString::FromUTF8(kLicensesText),
                wxDefaultPosition,
                wxDefaultSize,
                wxTE_MULTILINE | wxTE_READONLY | wxBORDER_NONE);
        text->SetMinSize(wxSize(600, 440));
        sizer->Add(text, 1, wxEXPAND | wxALL, 10);
        dialog.SetSizer(sizer);
        dialog.CentreOnParent();
        dialog.ShowModal();
    }

    void OnAbout(wxCommandEvent &event) {
        wxAboutDialogInfo info;
        info.SetName("mywxapp1");
        info.SetVersion("1.0.0");
        info.SetDescription("Minimal wxWidgets template application.");
        info.AddDeveloper("Allan Riordan Boll");

        auto icon = this->GetIcon();
        if (!icon.IsOk()) {
#if defined(__WXMSW__)
            icon.LoadFile("appicon", wxBITMAP_TYPE_ICO_RESOURCE);
#else
            icon.CopyFromBitmap(wxBitmap(appicon));
#endif
        }
        if (icon.IsOk()) {
            info.SetIcon(icon);
        }

        wxAboutBox(info, this);
    }
};
}  // namespace

class MyWxApp : public wxApp {
public:
    bool OnInit() override {
        auto *frame = new MainFrame();
        frame->Show();
        this->SetTopWindow(frame);
        return true;
    }
};

wxIMPLEMENT_APP(MyWxApp);
