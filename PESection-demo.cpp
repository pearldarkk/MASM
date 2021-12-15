#include<windows.h>
#include<iostream>

int main()
{
    LPCSTR fileName = "inputFile.exe";
    HANDLE hFile;
    HANDLE hFileMapping;
    LPVOID lpFileBase;
    PIMAGE_DOS_HEADER dosHeader;
    PIMAGE_NT_HEADERS peHeader;
    PIMAGE_SECTION_HEADER sectionHeader;

    hFile = CreateFileA(fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

    if (hFile == INVALID_HANDLE_VALUE)
    {
        std::cout << "\n CreateFile failed \n";
        return 1;
    }

    hFileMapping = CreateFileMapping(hFile, NULL, PAGE_READONLY, 0, 0, NULL);

    if (hFileMapping == 0)
    {
        std::cout << "\n CreateFileMapping failed \n";
        CloseHandle(hFile);
        return 1;
    }

    lpFileBase = MapViewOfFile(hFileMapping, FILE_MAP_READ, 0, 0, 0);

    if (lpFileBase == 0)
    {
        std::cout << "\n MapViewOfFile failed \n";
        CloseHandle(hFileMapping);
        CloseHandle(hFile);
        return 1;
    }

    dosHeader = (PIMAGE_DOS_HEADER)lpFileBase;
    if (dosHeader->e_magic == IMAGE_DOS_SIGNATURE)
    {
        std::cout << "\n DOS Signature (MZ) Matched \n";

        peHeader = (PIMAGE_NT_HEADERS)((u_char*)dosHeader + dosHeader->e_lfanew);
        if (peHeader->Signature == IMAGE_NT_SIGNATURE)
        {
            std::cout << "\n PE Signature (PE) Matched \n";
            sectionHeader = IMAGE_FIRST_SECTION(peHeader);
            UINT nSectionCount = peHeader->FileHeader.NumberOfSections;

            //No of Sections
            std::cout << "\n No of Sections : " << nSectionCount << "  \n";

            //sectionHeader contains pointer to first section
            //sectionHeader++ will move to next section
            for (UINT i = 0; i < nSectionCount; ++i, ++sectionHeader)
            {
                std::cout << "\n-----------------------------------------------\n";
                std::cout << "\n Section Name : " << sectionHeader->Name << " \n";
                //address can be obtained as (PBYTE)lpFileBase+sectionHeader->PointerToRawData
                std::cout << "\n Size of section data : " << sectionHeader->Misc.VirtualSize << " \n";
                std::cout << "\n-----------------------------------------------\n";
            }

            //Now sectionHeader will have pointer to last section
            //if you add sectionHeader++ in for loop instead of ++sectionHeader it will point to memory after last section

        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 1;
    }
    return 0;
}