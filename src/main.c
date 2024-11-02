#include <efi.h>
#include <efiapi.h>
#include <eficon.h>
#include <efidef.h>
#include <efierr.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;
    EFI_INPUT_KEY Key;

    ST = SystemTable;
    
    Status = ST->ConOut->OutputString(ST->ConOut, L"Waiting for input to boot\r\n");

    if (EFI_ERROR(Status)) {
        return Status;
    }

    Status = ST->ConIn->Reset(ST->ConIn, FALSE); // empty buffer

    if (EFI_ERROR(Status)) {
        return Status;
    }

    while ((Status = ST->ConIn->ReadKeyStroke(ST->ConIn, &Key)) == EFI_NOT_READY); // polling for key

    return Status;
}
