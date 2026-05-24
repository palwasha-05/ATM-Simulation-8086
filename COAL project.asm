INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "***** ATM SIMULATOR *****",0

mainMenuMsg BYTE "---- MAIN MENU ----",0
createAccOption BYTE "1. Create New Account",0
loginOption BYTE "2. Login to Account",0
exitOption BYTE "3. Exit",0
mainChoiceMsg BYTE "Enter choice: ",0

setPinMsg BYTE "Set 4-digit PIN: ",0
dupPinMsg BYTE "PIN already exists!",0
invalidPinMsg BYTE "Invalid PIN! Must be exactly 4 numeric digits.",0
initDepositMsg BYTE "Enter initial deposit (>=5000): ",0
accCreatedMsg BYTE "Account created successfully!",0
moreAccMsg BYTE "Create another account? (1=YES, 0=NO): ",0
accountsDoneMsg BYTE "All 10 accounts have been created.",0

loginMsg BYTE "---- LOGIN ----",0
enterPinMsg BYTE "Enter PIN: ",0
loginFailMsg BYTE "Invalid PIN!",0
loginOkMsg BYTE "Login successful!",0

userMenuMsg BYTE "---- ACCOUNT MENU ----",0
checkBalOption BYTE "1. Check Balance",0
withdrawOption BYTE "2. Withdraw",0
depositOption BYTE "3. Deposit",0
backOption BYTE "4. Back to Main Menu",0

enterAmtMsg BYTE "Enter amount: ",0
balanceMsg BYTE "Current Balance: ",0
invalidAmtMsg BYTE "Invalid amount! Must be multiple of 500.",0
insufficientMsg BYTE "Insufficient balance!",0
withdrawLimitMsg BYTE "Maximum withdrawal per transaction is 25000.",0

goodbyeMsg BYTE "Thank you for using ATM!",0

MAX_ACCOUNTS EQU 10

savedPINs BYTE MAX_ACCOUNTS*4 DUP(0)
balances DWORD MAX_ACCOUNTS DUP(0)

accountCount DWORD 0
loggedIndex DWORD ?
pinBuffer BYTE 10 DUP(0)
choice DWORD ?
amount DWORD ?

.code

main PROC
    call Clrscr
    mov edx, OFFSET welcomeMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line

MainMenu:
    mov edx, OFFSET mainMenuMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    mov edx, OFFSET createAccOption
    call WriteString
    call Crlf
    mov edx, OFFSET loginOption
    call WriteString
    call Crlf
    mov edx, OFFSET exitOption
    call WriteString
    call Crlf
    call Crlf        ; blank line
    mov edx, OFFSET mainChoiceMsg
    call WriteString
    call ReadInt
    mov choice, eax

    cmp eax, 1
    je CreateAccountMenu
    cmp eax, 2
    je LoginMenu
    cmp eax, 3
    je ExitProgram
    jmp MainMenu

; ===== CREATE ACCOUNT =====
CreateAccountMenu:
    cmp accountCount, MAX_ACCOUNTS
    jae AccountsCompleted

CreateAcc:
    call CreateAccount

    cmp accountCount, MAX_ACCOUNTS
    je AccountsCompleted

    mov edx, OFFSET moreAccMsg
    call WriteString
    call ReadInt
    cmp eax, 1
    je CreateAcc
    jmp MainMenu

AccountsCompleted:
    mov edx, OFFSET accountsDoneMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    jmp MainMenu

; ===== LOGIN =====
LoginMenu:
    mov edx, OFFSET loginMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    mov edx, OFFSET enterPinMsg
    call WriteString
    mov edx, OFFSET pinBuffer
    mov ecx, 5
    call ReadString

    cmp eax, 4
    jne LoginFail

    call FindAccountByPIN
    cmp eax, -1
    je LoginFail

    mov loggedIndex, eax
    mov edx, OFFSET loginOkMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    jmp UserMenu

LoginFail:
    mov edx, OFFSET loginFailMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    jmp MainMenu

; ===== USER MENU =====
UserMenu:
    mov edx, OFFSET userMenuMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    mov edx, OFFSET checkBalOption
    call WriteString
    call Crlf
    mov edx, OFFSET withdrawOption
    call WriteString
    call Crlf
    mov edx, OFFSET depositOption
    call WriteString
    call Crlf
    mov edx, OFFSET backOption
    call WriteString
    call Crlf
    call Crlf        ; blank line

    mov edx, OFFSET mainChoiceMsg
    call WriteString
    call ReadInt
    mov choice, eax

    cmp eax, 1
    je CheckBalance
    cmp eax, 2
    je Withdraw
    cmp eax, 3
    je Deposit
    cmp eax, 4
    je MainMenu
    jmp UserMenu


CheckBalance:
    mov eax, loggedIndex
    mov edx, OFFSET balances
    mov eax, [edx + eax*4]
    mov edx, OFFSET balanceMsg
    call WriteString
    call WriteDec
    call Crlf
    call Crlf        ; blank line
    jmp UserMenu

Withdraw:
    mov edx, OFFSET enterAmtMsg
    call WriteString
    call ReadInt
    mov amount, eax

    cmp amount, 500
    jb InvalidWithdraw
    cmp amount, 25000
    ja InvalidWithdraw
    mov ebx, 500
    xor edx, edx
    div ebx
    cmp edx, 0
    jne InvalidWithdraw

    mov eax, loggedIndex
    mov edx, OFFSET balances
    mov ebx, [edx + eax*4]
    cmp amount, ebx
    jg NoMoney

    sub ebx, amount
    mov [edx + eax*4], ebx

    mov edx, OFFSET balanceMsg
    call WriteString
    mov eax, loggedIndex
    mov edx, OFFSET balances
    mov eax, [edx + eax*4]
    call WriteDec
    call Crlf
    call Crlf        ; blank line
    jmp UserMenu

InvalidWithdraw:
    mov edx, OFFSET invalidAmtMsg
    call WriteString
    call Crlf
    call Crlf
    jmp UserMenu

NoMoney:
    mov edx, OFFSET insufficientMsg
    call WriteString
    call Crlf
    call Crlf
    jmp UserMenu

Deposit:
    mov edx, OFFSET enterAmtMsg
    call WriteString
    call ReadInt
    mov amount, eax

    cmp amount, 500
    jb InvalidDeposit
    mov ebx, 500
    xor edx, edx
    div ebx
    cmp edx, 0
    jne InvalidDeposit

    mov eax, loggedIndex
    mov edx, OFFSET balances
    mov ebx, amount
    add [edx + eax*4], ebx

    mov edx, OFFSET balanceMsg
    call WriteString
    mov eax, loggedIndex
    mov edx, OFFSET balances
    mov eax, [edx + eax*4]
    call WriteDec
    call Crlf
    call Crlf        ; blank line
    jmp UserMenu

InvalidDeposit:
    mov edx, OFFSET invalidAmtMsg
    call WriteString
    call Crlf
    call Crlf
    jmp UserMenu

ExitProgram:
    mov edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    invoke ExitProcess, 0

main ENDP

; ===== CREATE ACCOUNT PROC =====
CreateAccount PROC
RetryPIN:
    mov edx, OFFSET setPinMsg
    call WriteString
    mov edx, OFFSET pinBuffer
    mov ecx, 5
    call ReadString

    cmp eax, 4
    jne BadPIN

    mov esi, OFFSET pinBuffer
    mov ecx, 4
CheckDigits:
    mov al, [esi]
    cmp al, '0'
    jb BadPIN
    cmp al, '9'
    ja BadPIN
    inc esi
    loop CheckDigits

    call FindAccountByPIN
    cmp eax, -1
    jne DuplicatePIN

RetryDeposit:
    mov edx, OFFSET initDepositMsg
    call WriteString
    call ReadInt
    cmp eax, 5000
    jb BadDeposit

    mov ebx, accountCount
    mov edx, OFFSET balances
    mov [edx + ebx*4], eax
    inc accountCount

    mov esi, OFFSET pinBuffer
    mov edi, OFFSET savedPINs
    mov eax, accountCount
    dec eax
    mov ecx, 4
    imul eax, 4
    add edi, eax
CopyPinLoop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop CopyPinLoop

    mov edx, OFFSET accCreatedMsg
    call WriteString
    call Crlf
    call Crlf        ; blank line
    ret

BadPIN:
    mov edx, OFFSET invalidPinMsg
    call WriteString
    call Crlf
    call Crlf
    jmp RetryPIN

DuplicatePIN:
    mov edx, OFFSET dupPinMsg
    call WriteString
    call Crlf
    call Crlf
    jmp RetryPIN

BadDeposit:
    mov edx, OFFSET invalidAmtMsg
    call WriteString
    call Crlf
    call Crlf
    jmp RetryDeposit
CreateAccount ENDP

; ===== FIND ACCOUNT =====
FindAccountByPIN PROC
    mov ecx, accountCount
    xor esi, esi

SearchLoop:
    cmp esi, ecx
    je NotFound

    mov edi, 0
CompareLoop:
    mov al, savedPINs[esi*4 + edi]
    cmp al, pinBuffer[edi]
    jne NextAccount
    inc edi
    cmp edi, 4
    jl CompareLoop

    mov eax, esi
    ret

NextAccount:
    inc esi
    jmp SearchLoop

NotFound:
    mov eax, -1
    ret
FindAccountByPIN ENDP

END main
