```mermaid
sequenceDiagram
	autonumber
   	participant A as Alice
    participant B as Bob
    participant D as Absentia DApp
    participant D2 as PET Sub-DApp
    participant T1 as Trustee 1*
		participant T2 as Trustee 2

    A->>D: Deposit Ciphertext and Fee
    B->>D: Deposit Ciphertext and Fee
    
    
    T1->>D: Load Circuit Ciphertexts
    D->>D: Lock Fees
    T1->>D: Create PET Contracts
    D->>D2: Create PET Contracts
    
    loop For each PET
    
    T1->>D2: PET: Subtraction
    T1->>D2: PET: Submit Blinded Value and ZKP
    T2->>D2: PET: Submit Blinded Value and ZKP
    T1->>D2: PET: Partial Decryption and ZKP
    T2->>D2: PET: Partial Decryption and ZKP
    D2->>D: Equal or Not Equal
    end
    
    T1->>D: Determine Output
    T1->>D: Output: Partial Decryption and ZKP 
    T2->>D: Output: Partial Decryption and ZKP 
    D->>D: Transfer Fees to Trustees

    D->>A: Retreive Result
    D->>B: Retreive Result
    
    
```




```sequence
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```



