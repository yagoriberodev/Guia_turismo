# Guia de Turismo

App Flutter com cadastro com foto, login, lista de lugares turísticos e distância até cada lugar. O cadastro, o perfil e os lugares usam o banco da [API da turma](https://guia.liliaborges.com.br/api-docs/).

## Rodar o app

```powershell
flutter pub get
flutter run -d chrome
```

Para testar no Android, conecte um telefone com depuração USB ou inicie um emulador com Google Play. Use `flutter devices` para encontrar o ID e execute `flutter run -d ID_DO_DISPOSITIVO`.

## Ativar o login com Google

No [Firebase Console](https://console.firebase.google.com/), abra o projeto e habilite **Authentication → Método de login → Google**. Escolha um e-mail de suporte e salve.

- Para o navegador, cadastre um app Web no Firebase e adicione `localhost` a **Authentication → Configurações → Domínios autorizados**.
- Para Android, cadastre o pacote `com.example.projeto_retorno`. Execute `.\gradlew.bat signingReport` na pasta `android` e adicione o SHA-1 do seu build ao app no Firebase. Baixe o `google-services.json` atualizado após habilitar o Google.

Na raiz do projeto, crie `firebase.local.json`:

```json
{
  "FIREBASE_API_KEY": "apiKey do app",
  "FIREBASE_APP_ID": "appId do app",
  "FIREBASE_PROJECT_ID": "projectId",
  "FIREBASE_SENDER_ID": "messagingSenderId",
  "GOOGLE_WEB_CLIENT_ID": "ID OAuth do tipo Web"
}
```

Para Web, copie a configuração do app Web e deixe `GOOGLE_WEB_CLIENT_ID` vazio. Para Android, use `current_key`, `mobilesdk_app_id`, `project_id`, `project_number` e o `client_id` com `client_type: 3` do `google-services.json`.

```powershell
flutter run -d chrome --dart-define-from-file=firebase.local.json
flutter run -d ID_DO_DISPOSITIVO --dart-define-from-file=firebase.local.json
```

O login Google cria uma sessão no Firebase Authentication, com nome, e-mail e foto da conta. O cadastro com e-mail grava o perfil no banco da API da turma, que emite seu próprio token de acesso. Os dois acessos exibem o catálogo público da API.

## Roteiro de apresentação

1. Abra **Criar conta**, selecione uma foto e conclua o cadastro.
2. Entre com e-mail e senha. Abra **Meu perfil** para mostrar a foto gravada.
3. Na lista de lugares, toque em **Usar minha localização** e permita o acesso. A distância em linha reta aparece em quilômetros.
4. Saia da conta e use **Entrar com Google**. Abra **Meu perfil** para mostrar os dados da conta Google.

## Estrutura

- `controllers` coordena cadastro, foto e acesso.
- `models` representa usuário e lugar.
- `screens` contém as telas de acesso e catálogo.
- `services` faz as chamadas à API, ao Firebase e à localização.
- `themes` e `widgets` concentram o visual e os componentes.
