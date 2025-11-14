# PGR301 Eksamen 2025 - Besvarelse

**Kandidatnummer:** 6

---

## Oppgave 1 - Terraform, S3 og Infrastruktur som Kode (15 poeng)

### Leveranser

#### Terraform-kode
- **Mappe:** [infra-s3/](infra-s3/)
- **Hovedfiler:**
  - [main.tf](infra-s3/main.tf) - S3 bucket og lifecycle konfiguration
  - [variables.tf](infra-s3/variables.tf) - Variable definisjoner
  - [outputs.tf](infra-s3/outputs.tf) - Output verdier
  - [README.md](infra-s3/README.md) - Dokumentasjon

#### GitHub Actions Workflow
- **Workflow-fil:** [.github/workflows/terraform-s3.yml](.github/workflows/terraform-s3.yml)
- **Workflow kjøringer:**
  - Pull Request validation: [Sett inn lenke til PR workflow her]
  - Successful apply: [Sett inn lenke til successful apply workflow her]

#### S3 Bucket
- **Bucket navn:** `kandidat-6-data`
- **Region:** `eu-west-1`
- **Backend state:** `s3://pgr301-terraform-state/infra-s3/terraform.tfstate`

### Implementasjonsdetaljer

#### Lifecycle Policy
Terraform-konfigurasjonen implementerer følgende lifecycle-strategi for filer under `midlertidig/` prefix:

1. **Transition til Glacier:** Filer flyttes til Glacier storage class etter 30 dager
2. **Sletting:** Filer slettes automatisk etter 90 dager
3. **Multipart upload cleanup:** Ufullstendige multipart uploads slettes etter 7 dager
4. **Versjon cleanup:** Gamle versjoner av filer slettes etter 90 dager

Filer utenfor `midlertidig/` prefikset lagres permanent uten lifecycle-regler.

#### Sikkerhet
- Server-side encryption (AES256) aktivert
- Versioning aktivert for å beskytte mot utilsiktet sletting
- Public access fullstendig blokkert
- Terraform state lagret sikkert i remote S3 backend

#### CI/CD Pipeline
GitHub Actions workflow kjører automatisk ved endringer i `infra-s3/` eller workflow-filen:

**På Pull Requests:**
- `terraform fmt -check` - Validerer formatering
- `terraform validate` - Validerer konfigurasjon
- `terraform plan` - Viser planlagte endringer
- Poster resultater som kommentar på PR

**På Push til Main:**
- Kjører samme valideringer
- `terraform apply -auto-approve` - Deployer infrastruktur
- Viser outputs i workflow summary

### Instruksjoner for bruk

1. **Kopier variabel-filen:**
   ```bash
   cd infra-s3
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Oppdater med ditt kandidatnummer:**
   ```hcl
   bucket_name = "kandidat-<DITT-NR>-data"
   ```

3. **Initialiser og deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **For GitHub Actions:**
   - Sett repository secrets: `AWS_ACCESS_KEY_ID` og `AWS_SECRET_ACCESS_KEY`
   - Push endringer til en branch og opprett PR for å se validering
   - Merge til main for å deploye infrastruktur

---

## Oppgave 2 - AWS Lambda, SAM og GitHub Actions (25 poeng)

[Kommer snart...]

---

## Oppgave 3 - Container og Docker (25 poeng)

[Kommer snart...]

---

## Oppgave 4 - Observabilitet, Metrikksamling og Overvåkningsinfrastruktur (25 poeng)

[Kommer snart...]

---

## Oppgave 5 - KI-assistert Systemutvikling og DevOps-prinsipper (10 poeng)

[Kommer snart...]

---

## Notater og refleksjoner

[Legg til dine egne notater og refleksjoner her...]
