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
- **Backend state:** Local state (S3 backend deaktivert grunnet tilgangsbegrensninger)

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

### Del A (10p): Deploy og test SAM-applikasjonen

#### Leveranser

- **API Gateway URL:** https://8z9glu80ta.execute-api.eu-west-1.amazonaws.com/Prod/analyze/
- **S3 objekt:** [Vil bli fylt ut etter testing - sjekk s3://kandidat-6-data/midlertidig/ etter API test]

#### Implementasjon

SAM-applikasjonen er konfigurert med:
- **S3 Bucket:** `kandidat-6-data` (oppdatert i template.yaml)
- **Stack Name:** `aialpha-sentiment-kandidat-6`
- **Runtime:** Python 3.11
- **Lambda Timeout:** 30 sekunder
- **Memory:** 256 MB

Applikasjonen bruker AWS Comprehend for sentimentanalyse og lagrer resultater under `midlertidig/` prefix i S3-bucketen, slik at lifecycle-policyen fra Oppgave 1 automatisk sletter dem etter 90 dager.

### Del B (15p): GitHub Actions Workflow

#### Leveranser

- **Workflow-fil:** [.github/workflows/sam-deploy.yml](.github/workflows/sam-deploy.yml)
- **Successful deploy:** https://github.com/AlsosCode/PGR301-DevOps-Exam/actions/runs/[WORKFLOW_RUN_ID]
- **PR validation:** [Vil bli opprettet når vi tester PR-funksjonalitet]

#### Implementerte forbedringer

Den opprinnelige workflowen hadde flere problemer som er nå rettet:

**Problemer i original workflow:**
1. ❌ Deployet til AWS på **hver** pull request (ikke god DevOps-praksis)
2. ❌ Manglet `sam validate` og `sam build` steg
3. ❌ Hardkodet verdier (stack-navn, bucket-navn)

**Løsning:**

Workflowen er nå delt i to jobs:

**1. `validate-and-build` job** (kjører på både PR og push):
- ✅ Kjører `sam validate` for å verifisere template syntax
- ✅ Kjører `sam build` for å bygge applikasjonen
- ✅ Laster opp build artifacts for deployment-jobben

**2. `deploy` job** (kjører KUN på push til main):
- ✅ Betinget kjøring: `if: github.event_name == 'push' && github.ref == 'refs/heads/main'`
- ✅ Laster ned build artifacts
- ✅ Kjører `sam deploy` med riktig konfigurasjon
- ✅ Henter API Gateway URL fra CloudFormation outputs
- ✅ Tester deployed endepunkt automatisk

**Bruk av environment variabler:**
```yaml
env:
  AWS_REGION: eu-west-1
  STACK_NAME: aialpha-sentiment-kandidat-6
  S3_BUCKET: kandidat-6-data
```

Dette gjør workflowen enkel å tilpasse for andre kandidater ved å kun endre verdiene i `env`-seksjonen.

#### Instruksjoner til sensor

For å få workflowen til å kjøre i din fork:

1. **Legg til GitHub Secrets:**
   - Gå til Settings → Secrets and variables → Actions
   - Legg til `AWS_ACCESS_KEY_ID`
   - Legg til `AWS_SECRET_ACCESS_KEY`

2. **Oppdater environment variabler:**
   - Åpne `.github/workflows/sam-deploy.yml`
   - Endre `STACK_NAME` og `S3_BUCKET` til dine verdier i `env`-seksjonen

3. **Deploy Terraform infrastruktur først:**
   - Kjør Terraform workflow for å opprette S3 bucketen
   - SAM deployment vil feile uten eksisterende S3 bucket

4. **Trigger workflow:**
   - Push en endring til `sam-comprehend/` mappen
   - Eller manuelt trigger fra Actions-fanen

#### Testing

For å teste API-et lokalt:
```bash
curl -X POST <API-GATEWAY-URL> \
  -H "Content-Type: application/json" \
  -d '{"text": "Apple launches groundbreaking new AI features while Microsoft faces security concerns."}'
```

Workflowen tester også automatisk endepunktet etter deployment og viser resultatet i workflow-loggen.

---

## Oppgave 3 - Container og Docker (25 poeng)

### Del A (10p): Containeriser Spring Boot-applikasjonen

#### Leveranser

- **Dockerfile:** [sentiment-docker/Dockerfile](sentiment-docker/Dockerfile)
- **Docker Hub Repository:** https://hub.docker.com/r/alsoscode/sentiment-docker

#### Implementasjon

Dockerfilen bruker **multi-stage build** for optimal imagestørrelse og effektivitet:

**Build Stage (Maven + Java 21):**
```dockerfile
FROM maven:3.9-amazoncorretto-21 AS build
```
- Bruker Maven for å bygge applikasjonen
- Dependency caching for raskere rebuilds
- Kompilerer og pakker Spring Boot applikasjonen

**Runtime Stage (Corretto Alpine):**
```dockerfile
FROM amazoncorretto:21-alpine
```
- Minimal Alpine-basert runtime image
- Non-root user (`spring:spring`) for sikkerhet
- JVM container support aktivert
- Health check konfigurert
- Eksponerer port 8080

**Sikkerhetsfeatures:**
- ✅ Non-root user execution
- ✅ Minimal Alpine base image
- ✅ Health checks for container orchestration
- ✅ Environment-based secrets
- ✅ JVM tuned for containers

### Del B (15p): GitHub Actions workflow for Docker Hub

#### Leveranser

- **Workflow-fil:** [.github/workflows/docker-build.yml](.github/workflows/docker-build.yml)
- **Successful build:** https://github.com/AlsosCode/PGR301-DevOps-Exam/actions/workflows/docker-build.yml
- **Container image:** `alsoscode/sentiment-docker:latest`
- **Docker Hub Repository:** https://hub.docker.com/r/alsoscode/sentiment-docker

#### Tagging-strategi

**Multi-tag strategi** for fleksibilitet og sporbarhet:

1. **`latest`** - Alltid siste build fra main
2. **`kandidat-6`** - Kandidatspesifikk tag
3. **`kandidat-6-sha-<commit>`** - Commit-spesifikke tags for full traceability

**Hvorfor denne strategien?**
- `latest` gir alltid nyeste versjon
- `kandidat-6` gjør det enkelt for sensor
- SHA-tags gir full sporbarhet til eksakt commit

#### Instruksjoner til sensor

1. Opprett Docker Hub konto og access token
2. Legg til GitHub Secrets: `DOCKER_USERNAME` og `DOCKER_TOKEN`
3. Oppdater image navn i workflow
4. Push til `sentiment-docker/` for å trigge build

---

## Oppgave 4 - Observabilitet, Metrikksamling og Overvåkningsinfrastruktur (25 poeng)

[Kommer snart...]

---

## Oppgave 5 - KI-assistert Systemutvikling og DevOps-prinsipper (10 poeng)

[Kommer snart...]

---

## Notater og refleksjoner

[Legg til dine egne notater og refleksjoner her...]
