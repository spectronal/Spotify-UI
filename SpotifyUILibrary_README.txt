<div align="center">

# 🎵 Spotify UI Library

### Uma UI Library moderna para Roblox, escrita em Luau e inspirada no visual do Spotify.

<img alt="Versão" src="https://img.shields.io/badge/versão-1.1.0-1DB954?style=for-the-badge">
<img alt="Luau" src="https://img.shields.io/badge/Luau-Roblox-00A2FF?style=for-the-badge&logo=roblox">
<img alt="Cliente" src="https://img.shields.io/badge/execução-LocalScript-181818?style=for-the-badge">
<img alt="Dependências" src="https://img.shields.io/badge/dependências-nenhuma-1DB954?style=for-the-badge">

<br><br>

</div>

---

## ✨ Sobre

A **Spotify UI Library** é uma biblioteca de interface para Roblox focada em uma API simples, visual consistente e fácil manutenção. Ela oferece uma janela completa com sidebar, tabs, sections, componentes interativos, notificações, escala responsiva, keybind configurável e uma barra inferior inspirada no “Now Playing” do Spotify.

A biblioteca funciona em um único `ModuleScript`, não exige pacotes externos e foi projetada para ser usada no cliente por meio de um `LocalScript`.

> [!IMPORTANT]
> Esta biblioteca deve ser executada no cliente. Não use `CreateWindow` em `Script` de servidor.

---

## 📚 Sumário

- [Recursos](#-recursos)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Início rápido](#-início-rápido)
- [Estrutura da API](#-estrutura-da-api)
- [Configuração da janela](#-configuração-da-janela)
- [Tabs e Sections](#-tabs-e-sections)
- [Componentes](#-componentes)
- [Settings e Keybind](#-settings-e-keybind)
- [Barra Now Playing](#-barra-now-playing)
- [Notificações](#-notificações)
- [Responsividade e escala](#-responsividade-e-escala)
- [Tema](#-tema)
- [Limpeza e destruição](#-limpeza-e-destruição)
- [Exemplo completo](#-exemplo-completo)
- [Update Logs](#-update-logs)
- [Como adicionar um novo Update Log](#-como-adicionar-um-novo-update-log)
- [Problemas comuns](#-problemas-comuns)

---

## 🚀 Recursos

- Visual dark inspirado no Spotify.
- Sidebar com ícone, texto e indicador de tab ativa.
- Tab `Settings` automática e separada das tabs principais.
- Keybind configurável para abrir e fechar a interface.
- Barra inferior com ícone, nome e criador da experiência.
- Janela arrastável por mouse e toque.
- Escala manual pelos botões `-` e `+`.
- Escala automática baseada no `ViewportSize`.
- Compatibilidade com diferentes resoluções e proporções de tela.
- Tabs e páginas com rolagem automática.
- Sections com altura automática.
- Componentes com métodos para atualização durante a execução.
- Notificações temporárias com barra de progresso.
- Limpeza de conexões, threads, tweens e instâncias ao destruir a UI.
- Nenhuma dependência externa.

### Componentes disponíveis

| Componente | Descrição |
|---|---|
| `Window` | Janela principal da interface. |
| `Tab` | Item de navegação da sidebar. |
| `Section` | Agrupador visual de componentes. |
| `Button` | Executa uma ação ao clicar. |
| `Toggle` | Alterna entre ligado e desligado. |
| `Slider` | Seleciona um valor numérico. |
| `Dropdown` | Seleciona uma opção em uma lista. |
| `Input` | Campo para entrada de texto. |
| `Label` | Exibe um texto simples. |
| `Paragraph` | Exibe título e conteúdo em múltiplas linhas. |
| `Keybind Picker` | Captura e altera uma tecla. |
| `Notification` | Exibe um toast temporário. |

---

## ✅ Requisitos

- Roblox Studio.
- Um `LocalScript` para inicializar a biblioteca.
- O `ModuleScript` disponível para o cliente, normalmente em `ReplicatedStorage`.

A biblioteca utiliza apenas serviços nativos do Roblox:

- `Players`
- `TweenService`
- `MarketplaceService`
- `UserInputService`
- `Workspace`

---

## 📦 Instalação

### 1. Crie o ModuleScript

No Explorer do Roblox Studio, crie:

```text
ReplicatedStorage
└── SpotifyUILibrary (ModuleScript)
```

Cole todo o conteúdo de `SpotifyUILibrary.lua` nesse `ModuleScript`.

### 2. Crie o LocalScript

Crie um `LocalScript` em um dos locais abaixo:

```text
StarterPlayer
└── StarterPlayerScripts
    └── SpotifyUIExample (LocalScript)
```

ou:

```text
StarterGui
└── SpotifyUIExample (LocalScript)
```

### 3. Importe a biblioteca

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("SpotifyUILibrary"))
```

---

## ⚡ Início rápido

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("SpotifyUILibrary"))

local Window = Library:CreateWindow({
    Title = "Meu Menu",
    Subtitle = "Spotify UI Library",
})

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "⌂",
})

local MainSection = HomeTab:CreateSection("Controles principais")

MainSection:CreateButton({
    Text = "Clique aqui",
    Description = "Executa uma ação simples.",
    Callback = function()
        print("Botão pressionado")
    end,
})

MainSection:CreateToggle({
    Text = "Música ativada",
    Default = true,
    Callback = function(enabled)
        print("Música:", enabled)
    end,
})

MainSection:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Suffix = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})
```

---

## 🧱 Estrutura da API

A hierarquia principal é:

```text
Library
└── Window
    ├── Tab
    │   └── Section
    │       └── Componentes
    ├── Settings Tab automática
    ├── Now Playing
    └── Notifications
```

Exemplo:

```lua
local Window = Library:CreateWindow({ Title = "Menu" })
local Tab = Window:CreateTab("Home")
local Section = Tab:CreateSection("Jogabilidade")
local Toggle = Section:CreateToggle({ Text = "Auto Farm" })
```

Também é possível criar componentes diretamente em uma tab. Nesse caso, a biblioteca cria uma section interna sem título:

```lua
local AboutTab = Window:CreateTab("Sobre")

AboutTab:CreateLabel({
    Text = "Criado com Spotify UI Library",
})
```

---

## 🪟 Configuração da janela

```lua
local Window = Library:CreateWindow({
    Name = "MinhaInterface",
    Title = "Meu Menu",
    Subtitle = "Spotify UI Library",
    Size = Vector2.new(940, 590),
    Scale = 1,
    MinScale = 0.65,
    MaxScale = 1.5,
    AutoScale = true,
    MaxAutoScale = 1.2,
    ViewportMargin = 20,
    Keybind = Enum.KeyCode.RightShift,
    ShowNowPlaying = true,
    CloseBehavior = "Hide",
    DisplayOrder = 50,
    GameName = "Minha experiência",
    GameCreator = "Meu estúdio",
    GameIcon = "rbxassetid://123456789",
})
```

### Opções de `CreateWindow`

| Propriedade | Tipo | Padrão | Descrição |
|---|---:|---:|---|
| `Name` | `string` | Automático | Nome do `ScreenGui`. |
| `Title` | `string` | `Spotify UI` | Título exibido na sidebar. |
| `Subtitle` | `string` | `Roblox UI Library` | Subtítulo exibido abaixo do título. |
| `Parent` | `Instance` | `PlayerGui` | Parent personalizado para o `ScreenGui`. |
| `Size` | `Vector2` | `Vector2.new(940, 590)` | Tamanho base da janela. |
| `Scale` | `number` | `1` | Escala manual inicial. |
| `MinScale` | `number` | `0.65` | Menor escala permitida. |
| `MaxScale` | `number` | `1.5` | Maior escala permitida. |
| `AutoScale` | `boolean` | `true` | Ajusta a janela automaticamente ao viewport. |
| `MaxAutoScale` | `number` | `1.2` | Limite da escala automática. |
| `ViewportMargin` | `number` | `20` | Margem mantida entre a janela e a tela. |
| `Keybind` | `Enum.KeyCode`, `string`, `false` | `RightShift` | Tecla usada para abrir ou fechar a UI. Use `false` para desativar. |
| `ShowNowPlaying` | `boolean` | `true` | Exibe a barra inferior da experiência. |
| `CloseBehavior` | `"Hide"` ou `"Destroy"` | `"Hide"` | Define o comportamento do botão de fechar. |
| `DisplayOrder` | `number` | `50` | Ordem de exibição do `ScreenGui`. |
| `GameName` | `string` | Automático | Nome exibido na barra inferior. |
| `GameCreator` | `string` | Automático | Criador exibido na barra inferior. |
| `GameIcon` | `string` | Automático | Asset ou thumbnail usado como ícone. |

> [!NOTE]
> O tamanho informado é limitado internamente para evitar janelas pequenas ou grandes demais. A largura fica entre `720` e `1280`, e a altura entre `460` e `820`.

### Métodos da janela

| Método | Retorno | Descrição |
|---|---|---|
| `Window:CreateTab(config)` | `Tab` | Cria uma nova tab. |
| `Window:SelectTab(tabOuNome)` | `boolean` | Seleciona uma tab pelo objeto ou nome. |
| `Window:GetSettingsTab()` | `Tab` | Retorna a tab Settings automática. |
| `Window:SetKeybind(keyCode)` | `Window` | Altera ou remove o keybind da janela. |
| `Window:GetKeybind()` | `Enum.KeyCode?` | Retorna o keybind atual. |
| `Window:SetScale(scale)` | `Window` | Altera a escala manual. |
| `Window:GetScale()` | `number` | Retorna a escala manual. |
| `Window:GetEffectiveScale()` | `number` | Retorna a escala final aplicada após o AutoScale. |
| `Window:SetAutoScale(enabled)` | `Window` | Ativa ou desativa a escala automática. |
| `Window:SetSize(width, height)` | `Window` | Altera o tamanho base da janela. Também aceita `Vector2`. |
| `Window:GetSize()` | `Vector2` | Retorna o tamanho base atual. |
| `Window:SetTitle(title, subtitle?)` | `Window` | Atualiza o título e, opcionalmente, o subtítulo. |
| `Window:SetVisible(visible)` | `Window` | Mostra ou esconde a UI. |
| `Window:ToggleVisible()` | `boolean` | Alterna a visibilidade e retorna o novo estado. |
| `Window:SetGameInfo(config)` | `Window` | Atualiza nome, criador e ícone da barra inferior. |
| `Window:SetNowPlayingVisible(visible)` | `Window` | Mostra ou esconde a barra inferior. |
| `Window:Notify(config)` | `Notification?` | Exibe uma notificação. |
| `Window:Destroy()` | — | Destrói a janela e limpa seus recursos. |

### Exemplos de controle da janela

```lua
Window:SetScale(1.15)
Window:SetSize(1000, 640)
Window:SetTitle("Novo título", "Novo subtítulo")
Window:SetAutoScale(true)
Window:SetVisible(false)
Window:SetVisible(true)
```

---

## 🧭 Tabs e Sections

### Criando uma tab

A forma simples:

```lua
local HomeTab = Window:CreateTab("Home")
```

Com ícone de texto:

```lua
local MusicTab = Window:CreateTab({
    Name = "Música",
    Icon = "♫",
})
```

Com ícone de imagem:

```lua
local InventoryTab = Window:CreateTab({
    Name = "Inventário",
    Icon = "rbxassetid://123456789",
    IconColor = Library.Theme.Text,
})
```

### Opções de tab

| Propriedade | Tipo | Descrição |
|---|---:|---|
| `Name` | `string` | Nome da tab. |
| `Icon` | `string` | Símbolo, texto ou asset de imagem. |
| `IconColor` | `Color3` | Cor inicial do ícone. |

A biblioteca escolhe alguns ícones automaticamente para nomes comuns, como `Home`, `Sobre`, `Player`, `Music` e `Settings`.

### Métodos de tab

```lua
Tab:Select()
Tab:Destroy()
Tab:CreateSection("Nome da section")
```

Todos os métodos de criação de componentes também podem ser chamados diretamente pela tab:

```lua
Tab:CreateButton({...})
Tab:CreateToggle({...})
Tab:CreateSlider({...})
Tab:CreateDropdown({...})
Tab:CreateInput({...})
Tab:CreateLabel({...})
Tab:CreateParagraph({...})
Tab:CreateKeybindPicker({...})
```

### Criando uma section

```lua
local Section = HomeTab:CreateSection("Controles principais")
```

Para criar uma section sem título:

```lua
local Section = HomeTab:CreateSection(nil)
```

Para destruí-la:

```lua
Section:Destroy()
```

---

## 🧩 Componentes

Todos os componentes retornam um objeto de controle. Todos possuem:

```lua
Component:SetVisible(true)
Component:IsDestroyed()
Component:Destroy()
```

### Button

```lua
local Button = Section:CreateButton({
    Text = "Executar ação",
    Description = "Descrição opcional do botão.",
    Callback = function()
        print("Executado")
    end,
})
```

Métodos:

```lua
Button:SetText("Novo texto")
Button:Fire()
Button:SetVisible(false)
Button:Destroy()
```

---

### Toggle

```lua
local Toggle = Section:CreateToggle({
    Text = "Música ativada",
    Description = "Liga ou desliga a música do jogo.",
    Default = true,
    Callback = function(enabled)
        print(enabled)
    end,
})
```

Métodos:

```lua
Toggle:Set(true)
Toggle:Set(false, false) -- altera sem executar o callback
print(Toggle:Get())
```

---

### Slider

```lua
local Slider = Section:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print(value)
    end,
})
```

Métodos:

```lua
Slider:SetValue(50)
Slider:SetValue(80, false) -- altera sem executar o callback
print(Slider:GetValue())
```

---

### Dropdown

```lua
local Dropdown = Section:CreateDropdown({
    Text = "Qualidade",
    Options = { "Baixa", "Média", "Alta", "Ultra" },
    Default = "Alta",
    Placeholder = "Selecionar",
    Callback = function(value)
        print(value)
    end,
})
```

Métodos:

```lua
Dropdown:SetValue("Ultra")
Dropdown:SetValue("Média", false)
print(Dropdown:GetValue())

Dropdown:SetOptions({ "Opção A", "Opção B", "Opção C" })
Dropdown:SetOptions({ "Nova A", "Nova B" }, true) -- tenta manter o valor atual
Dropdown:SetOpen(true)
```

A lista cresce dentro do próprio layout e exibe até quatro opções antes de usar rolagem.

---

### Input

```lua
local Input = Section:CreateInput({
    Text = "Nome da playlist",
    Placeholder = "Minha playlist...",
    Default = "",
    ClearTextOnFocus = false,

    Changed = function(text)
        print("Enquanto digita:", text)
    end,

    Callback = function(text, enterPressed)
        print("Final:", text, "Enter:", enterPressed)
    end,
})
```

Métodos:

```lua
Input:SetText("Novo texto")
Input:SetText("Executar callback", true)
print(Input:GetText())
Input:Focus()
```

---

### Label

```lua
local Label = Section:CreateLabel({
    Text = "Versão " .. Library.Version,
    Bold = true,
    Color = Library.Theme.AccentHover,
    TextSize = 13,
    Alignment = Enum.TextXAlignment.Left,
})
```

Métodos:

```lua
Label:SetText("Texto atualizado")
Label:SetColor(Color3.fromRGB(255, 255, 255))
```

---

### Paragraph

```lua
local Paragraph = Section:CreateParagraph({
    Title = "Sobre",
    Content = "Conteúdo longo com quebra automática de linha.",
})
```

Métodos:

```lua
Paragraph:SetTitle("Novo título")
Paragraph:SetContent("Novo conteúdo")
```

> [!NOTE]
> `SetTitle` atualiza o título apenas quando o componente foi criado com a propriedade `Title`.

---

### Keybind Picker

```lua
local Keybind = Section:CreateKeybindPicker({
    Text = "Atalho do menu",
    Description = "Clique e pressione uma tecla.",
    Default = Enum.KeyCode.RightShift,
    BindToWindow = true,
    Callback = function(keyCode)
        print("Novo keybind:", keyCode)
    end,
})
```

Métodos:

```lua
Keybind:BeginListening()
Keybind:CancelListening()
Keybind:SetKeybind(Enum.KeyCode.F4)
Keybind:SetKeybind(nil) -- remove o keybind
print(Keybind:GetKeybind())
```

Comportamento durante a captura:

- O texto muda para `[ ... ]`.
- A próxima tecla do teclado é capturada.
- `Backspace` ou `Delete` remove o bind.
- Apenas um picker pode escutar por vez dentro da janela.
- Com `BindToWindow = true`, o valor altera o atalho principal da UI.
- Com `BindToWindow = false`, o componente mantém um valor independente.

---

## ⚙️ Settings e Keybind

A tab `Settings` é criada automaticamente no rodapé da sidebar.

```lua
local SettingsTab = Window:GetSettingsTab()
```

Ela já contém um `Keybind Picker` conectado à janela. A tecla padrão é:

```lua
Enum.KeyCode.RightShift
```

A tecla abre ou fecha a interface inteira:

```lua
Window:SetKeybind(Enum.KeyCode.F4)
```

Para remover o atalho:

```lua
Window:SetKeybind(nil)
```

Também é possível desativá-lo ao criar a janela:

```lua
local Window = Library:CreateWindow({
    Keybind = false,
})
```

O keybind não é executado quando:

- Outro Keybind Picker está capturando uma tecla.
- O input foi consumido pelo jogo.
- O jogador está digitando em um `TextBox`.

### Adicionando conteúdo à Settings

```lua
local SettingsTab = Window:GetSettingsTab()
local ExtraSection = SettingsTab:CreateSection("Preferências")

ExtraSection:CreateToggle({
    Text = "Mostrar notificações",
    Default = true,
})
```

> [!TIP]
> Criar uma tab manualmente com o nome `Settings` retorna a tab automática já existente, em vez de duplicá-la.

---

## 🎮 Barra Now Playing

A barra fixa inferior exibe informações da experiência atual:

- Ícone do jogo.
- Nome da experiência.
- Nome do criador.
- Indicador “Experiência atual”.

Por padrão, a biblioteca tenta preencher as informações automaticamente. Você pode sobrescrevê-las na criação:

```lua
local Window = Library:CreateWindow({
    GameName = "Minha experiência",
    GameCreator = "Meu estúdio",
    GameIcon = "rbxassetid://123456789",
})
```

Ou durante a execução:

```lua
Window:SetGameInfo({
    Name = "Novo nome",
    Creator = "Novo criador",
    Icon = "rbxassetid://123456789",
})
```

Para ocultar ou mostrar a barra:

```lua
Window:SetNowPlayingVisible(false)
Window:SetNowPlayingVisible(true)
```

Quando a largura disponível é menor, o indicador do lado direito é ocultado automaticamente para preservar o nome e o criador.

---

## 🔔 Notificações

### Pela janela

```lua
local Notification = Window:Notify({
    Title = "Tudo certo",
    Content = "A configuração foi salva.",
    Duration = 4,
    Color = Library.Theme.Accent,
})
```

### Pela biblioteca

`Library:Notify` envia a notificação para a última janela criada e ainda ativa:

```lua
Library:Notify({
    Title = "Aviso",
    Content = "Essa é uma notificação global.",
})
```

### Opções

| Propriedade | Tipo | Padrão | Descrição |
|---|---:|---:|---|
| `Title` | `string?` | — | Título opcional. |
| `Content` | `string` | `Notificação` | Conteúdo principal. |
| `Duration` | `number` | `4` | Tempo em segundos. Mínimo de `0.5`. |
| `Color` | `Color3` | `Theme.Accent` | Cor do indicador e da barra de progresso. |

Para fechar antes do tempo:

```lua
Notification:Dismiss()
```

---

## 📐 Responsividade e escala

A biblioteca calcula a escala final usando:

- Tamanho base da janela.
- Escala escolhida pelo usuário.
- Resolução atual da câmera.
- Margem configurada para o viewport.
- Limite de escala automática.

```lua
Window:SetScale(1.2)
Window:SetAutoScale(true)

print(Window:GetScale())
print(Window:GetEffectiveScale())
```

`GetScale()` retorna a escala solicitada pelo usuário. `GetEffectiveScale()` retorna a escala realmente aplicada após o ajuste ao viewport.

### Controles internos

A topbar possui:

- Botão `-` para reduzir a escala.
- Indicador percentual.
- Botão `+` para aumentar a escala.
- Botão `×` para ocultar ou destruir a UI.

### Comportamento responsivo

- A janela é mantida dentro da área visível da tela.
- A sidebar fica mais estreita em viewports menores.
- A barra inferior recalcula a área de conteúdo.
- Textos longos são truncados onde necessário.
- Tabs, páginas e dropdowns utilizam rolagem quando necessário.
- O arrasto funciona com mouse e toque.

---

## 🎨 Tema

O tema pode ser acessado por:

```lua
print(Library.Theme.Accent)
```

### Paleta padrão

| Campo | Cor |
|---|---|
| `Background` | `#121212` |
| `Sidebar` | `#181818` |
| `Card` | `#1E1E1E` |
| `CardHover` | `#282828` |
| `Input` | `#252525` |
| `Accent` | `#1DB954` |
| `AccentHover` | `#1ED760` |
| `Text` | `#FFFFFF` |
| `Subtext` | `#B3B3B3` |
| `Stroke` | `#3A3A3A` |
| `Divider` | `#303030` |
| `Selected` | `#242424` |
| `Danger` | `#E84855` |

Exemplo:

```lua
Section:CreateLabel({
    Text = "Status: online",
    Color = Library.Theme.AccentHover,
    Bold = true,
})
```

> [!WARNING]
> `Library.Theme` expõe a tabela atual, mas os componentes já criados não são atualizados automaticamente quando uma cor é alterada depois da criação.

---

## 🧹 Limpeza e destruição

A biblioteca possui um sistema interno de limpeza para conexões, threads, instâncias e objetos temporários.

### Destruir um componente

```lua
Toggle:Destroy()
```

### Destruir uma section

```lua
Section:Destroy()
```

### Destruir uma tab

```lua
Tab:Destroy()
```

### Destruir uma janela

```lua
Window:Destroy()
```

### Destruir todas as janelas

```lua
Library:DestroyAll()
```

Depois que um componente é destruído:

```lua
print(Component:IsDestroyed()) -- true
```

> [!CAUTION]
> Não continue chamando métodos de tabs ou sections depois de destruí-las.

---

## 💻 Exemplo completo

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("SpotifyUILibrary"))

local Window = Library:CreateWindow({
    Title = "Meu Menu",
    Subtitle = "Spotify UI Library",
    Size = Vector2.new(940, 590),
    Scale = 1,
    AutoScale = true,
    Keybind = Enum.KeyCode.RightShift,
    ShowNowPlaying = true,
    CloseBehavior = "Hide",
})

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "⌂",
})

local Controls = HomeTab:CreateSection("Controles principais")

Controls:CreateButton({
    Text = "Exibir notificação",
    Description = "Abre um toast no canto da tela.",
    Callback = function()
        Window:Notify({
            Title = "Spotify UI",
            Content = "O botão foi pressionado com sucesso.",
            Duration = 3,
        })
    end,
})

local MusicToggle = Controls:CreateToggle({
    Text = "Música ativada",
    Description = "Liga ou desliga a música do jogo.",
    Default = true,
    Callback = function(enabled)
        print("Música:", enabled)
    end,
})

local VolumeSlider = Controls:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})

local QualityDropdown = Controls:CreateDropdown({
    Text = "Qualidade",
    Options = { "Baixa", "Média", "Alta", "Ultra" },
    Default = "Alta",
    Callback = function(value)
        print("Qualidade:", value)
    end,
})

local PlaylistInput = Controls:CreateInput({
    Text = "Nome da playlist",
    Placeholder = "Minha playlist...",
    Callback = function(text, enterPressed)
        print("Playlist:", text, enterPressed)
    end,
})

local AboutTab = Window:CreateTab({
    Name = "Sobre",
    Icon = "i",
})

AboutTab:CreateParagraph({
    Title = "Spotify UI Library",
    Content = "Uma biblioteca visual para Roblox escrita em Luau.",
})

AboutTab:CreateLabel({
    Text = "Versão " .. Library.Version,
    Bold = true,
    Color = Library.Theme.AccentHover,
})

local SettingsTab = Window:GetSettingsTab()
local SettingsInfo = SettingsTab:CreateSection("Informações")

SettingsInfo:CreateLabel({
    Text = "O keybind é mantido somente durante a sessão atual.",
    Color = Library.Theme.Subtext,
})
```

---

# 📜 Update Logs

Esta seção registra as mudanças de cada versão. Mantenha a versão mais recente no topo.

## `v1.1.0` — 17/07/2026

### ✨ Adicionado

- Tab `Settings` automática e separada na parte inferior da sidebar.
- Componente `Keybind Picker`.
- Keybind padrão `RightShift` para abrir e fechar a UI.
- Barra inferior “Now Playing” com informações da experiência.
- Ícones nas tabs da sidebar.
- Indicador verde na tab selecionada.
- Métodos de destruição para componentes, sections e tabs.
- APIs `SetGameInfo`, `SetNowPlayingVisible`, `SetKeybind` e `GetKeybind`.

### 🔧 Alterado

- O botão de fechar agora usa `CloseBehavior = "Hide"` por padrão.
- A sidebar recebeu espaçamento e hierarquia visual mais próximos do Spotify.
- O layout responsivo agora reserva corretamente o espaço da barra inferior.
- A largura da sidebar se adapta a viewports menores.

### 🐛 Corrigido

- Conexões antigas de opções do dropdown ao reconstruir a lista.
- Elementos que podiam ultrapassar ou ficar atrás da barra inferior.
- Arrasto incorreto quando a janela estava escalada.
- Sombra desalinhada em relação à posição, tamanho ou escala da janela.
- Notificações e tarefas temporárias que podiam permanecer após destruir a UI.
- Referências de componentes, tabs e sections já destruídos.
- Keybind disparando durante captura de tecla ou digitação em `TextBox`.

<details>
<summary><strong>v1.0.0 — Primeira versão</strong></summary>

### ✨ Adicionado

- Janela principal com tema Spotify.
- Sidebar e sistema de tabs.
- Sections.
- Button, Toggle, Slider, Dropdown, Input, Label e Paragraph.
- Notificações.
- Escala manual e automática.
- Arrasto por mouse e toque.
- Sistema interno de limpeza de conexões.

</details>

---

## 📝 Como adicionar um novo Update Log

Copie o modelo abaixo, cole **acima da versão anterior** e substitua os campos necessários:

```md
## `vX.Y.Z` — DD/MM/AAAA

### ✨ Adicionado

- Nova feature adicionada.
- Novo componente ou nova API.

### 🔧 Alterado

- Comportamento atualizado.
- Ajuste visual ou alteração de API.

### 🐛 Corrigido

- Bug corrigido.
- Problema de responsividade resolvido.

### 🗑️ Removido

- Recurso removido ou descontinuado.

### ⚠️ Breaking Changes

- Mudança que exige alteração no código de quem usa a biblioteca.
```

### Sugestão de versionamento

Use o formato `MAJOR.MINOR.PATCH`:

| Parte | Quando alterar | Exemplo |
|---|---|---|
| `MAJOR` | Mudanças incompatíveis com versões anteriores. | `1.4.2` → `2.0.0` |
| `MINOR` | Novas features compatíveis. | `1.4.2` → `1.5.0` |
| `PATCH` | Correções de bugs e pequenos ajustes. | `1.4.2` → `1.4.3` |

Sempre atualize também a versão dentro do ModuleScript:

```lua
local Library = {
    Version = "1.2.0",
    _windows = {},
    _windowCounter = 0,
}
```

### Convenção recomendada para commits ou releases

```text
feat: adiciona componente ColorPicker
fix: corrige escala da sidebar em mobile
refactor: reorganiza sistema de cleanup
style: ajusta padding dos cards
docs: atualiza README e exemplos
```

---

## 🛠️ Problemas comuns

### `Players.LocalPlayer` é `nil`

A biblioteca está sendo executada no servidor. Mova o código de inicialização para um `LocalScript`.

### A interface não aparece

Confirme que:

- O ModuleScript está em `ReplicatedStorage`.
- O nome usado em `WaitForChild` está correto.
- O LocalScript está em `StarterPlayerScripts` ou `StarterGui`.
- Nenhum erro anterior interrompeu o script.

### A janela fecha e não volta

Caso esteja usando:

```lua
CloseBehavior = "Destroy"
```

A janela é removida completamente. Use o padrão `"Hide"` para reabri-la pelo keybind.

### O keybind não funciona

Verifique:

- Se o keybind não foi removido com `SetKeybind(nil)`.
- Se o jogador não está digitando em um `TextBox`.
- Se outro Keybind Picker não está escutando.
- Se o input não foi consumido por outra interface do jogo.

### A janela parece menor que a escala configurada

Com `AutoScale = true`, a biblioteca pode reduzir a escala para manter a janela dentro do viewport. Compare:

```lua
print(Window:GetScale())
print(Window:GetEffectiveScale())
```

### O nome ou criador do jogo não carregou

Você pode informar os dados manualmente:

```lua
Window:SetGameInfo({
    Name = "Nome do jogo",
    Creator = "Nome do criador",
    Icon = "rbxassetid://123456789",
})
```

### Um componente não é mais necessário

Destrua-o para remover a interface e suas conexões:

```lua
Component:Destroy()
```

---

## 🤝 Contribuição

Ao evoluir a biblioteca:

1. Preserve a API existente sempre que possível.
2. Registre novas conexões no sistema de limpeza.
3. Teste mouse e toque.
4. Teste resoluções pequenas e ultrawide.
5. Verifique `ZIndex`, clipping e rolagem.
6. Adicione a mudança aos Update Logs.
7. Atualize `Library.Version`.

---

## 📄 Licença

Nenhuma licença foi definida neste pacote. Antes de publicar a biblioteca em um repositório público, adicione um arquivo `LICENSE` com os termos de uso desejados.

---

<div align="center">

Feito em **Luau** para **Roblox** com inspiração visual no **Spotify**.

`Spotify UI Library v1.1.0`

</div>
