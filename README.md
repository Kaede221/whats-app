# Whats Now

> Manage Now - 你的个人任务管理助手

**Whats Now** 是一个基于 Flutter 开发的现代化任务管理应用，旨在帮助你高效地组织和管理日常任务。它提供了简洁直观的用户界面，支持多平台运行（Android, iOS, Web, Windows, macOS）。

## ✨ 主要功能

- **任务管理**
  - 📝 **创建任务**：快速添加任务，支持设置标题、描述、优先级和截止日期。
  - 🏷️ **任务分组**：通过不同的分组（如收集箱）来整理你的任务。
  - ✅ **任务状态**：标记任务完成状态，支持一键清除已完成任务。
  - 🗑️ **删除任务**：轻松移除不再需要的任务。

- **智能视图**
  - 📅 **日期筛选**：查看“今天”、“最近7天”的任务。
  - 📂 **分组查看**：按项目或类别筛选任务。
  - 🔍 **全部任务**：一览所有待办事项。

- **个性化体验**
  - 🎨 **动态主题**：支持亮色/暗色模式切换，可自定义主题种子颜色。
  - 🌍 **多语言支持**：内置中英文支持（默认简体中文）。

- **数据持久化**
  - 💾 **本地存储**：使用本地存储保存你的所有数据，保护隐私且无需联网。

## 🛠️ 技术栈

本项目使用 Flutter 框架开发，主要使用了以下技术和库：

- **Flutter SDK**: ^3.10.1
- **状态管理**: 使用原生 `ChangeNotifier` 和 `ListenableBuilder` 进行轻量级状态管理。
- **数据存储**: `shared_preferences` 用于本地数据持久化。
- **国际化**: `flutter_localizations` 提供多语言支持。
- **UI 组件**: Material Design 3 风格组件。

## 📂 项目结构

项目采用 Feature-first 的架构模式：

```
lib/
├── core/               # 核心功能（常量、服务、主题等）
│   ├── constants/      # 应用常量
│   ├── services/       # 基础服务（如存储服务）
│   └── theme/          # 主题配置
├── features/           # 业务功能模块
│   ├── shell/          # 应用外壳（导航结构）
│   ├── settings/       # 设置模块
│   └── tasks/          # 任务管理模块（核心业务）
│       ├── domain/     # 业务逻辑（模型、控制器）
│       └── presentation/ # UI 层（页面、组件）
└── main.dart           # 应用入口
```

## 🚀 快速开始

### 环境要求

- Flutter SDK
- Dart SDK
- Android Studio / VS Code

### 运行项目

1. **克隆项目**

   ```bash
   git clone https://github.com/Kaede221/whats-now.git
   cd whats_app_kaede
   ```

2. **安装依赖**

   ```bash
   flutter pub get
   ```

3. **运行应用**

   ```bash
   flutter run
   ```

## 📦 构建发布

- **Android APK**: `flutter build apk`
- **iOS IPA**: `flutter build ios` (需要 macOS)
- **Web**: `flutter build web`

## 👤 作者

**KaedeShimizu**

- GitHub: [@Kaede221](https://github.com/Kaede221)

## 📄 许可证

本项目仅供个人学习和使用。