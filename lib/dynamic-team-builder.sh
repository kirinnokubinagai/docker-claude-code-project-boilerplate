#!/bin/bash

# Dynamic Team Builder - プロダクトに応じた最適なチーム構成を自動生成

# 必要な関数をインポート
source "$SCRIPT_DIR/lib/core-lib.sh" 2>/dev/null || true

# プロダクトタイプに基づくチーム構成を決定
analyze_and_build_teams() {
    local product_requirements="$1"
    local teams_json="$WORKSPACE/config/teams.json"
    
    log_info "プロダクト要件を分析してチーム構成を決定中..."
    
    # AIが要件を分析してチーム構成を決定するプロンプト
    cat << EOF

=== プロダクト要件分析 ===
$product_requirements

上記の要件に基づいて、最適なチーム構成を決定してください。
以下の形式でteams.jsonを生成してください：

{
  "project_name": "プロジェクト名",
  "project_type": "web-app|mobile-app|ai-product|blockchain|enterprise",
  "analyzed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "teams": [
    {
      "id": "frontend",
      "name": "Frontend Team",
      "description": "UI/UX開発",
      "member_count": 3,
      "tech_stack": "Next.js 14, React 18, TypeScript",
      "branch": "team/frontend",
      "active": true,
      "justification": "モダンなWebアプリケーションのため"
    }
  ]
}

プロジェクトの複雑さと規模に応じて、必要なチームとメンバー数を決定してください。
EOF
}

# Master用の動的チーム構築プロンプト
generate_master_dynamic_prompt() {
    cat << 'EOF'
# 🚀 動的チーム構築システム

## あなたの役割

あなたはMaster Architectとして、プロジェクトの要件に基づいて最適なチーム構成を自動的に決定します。

## チーム構築の流れ

1. **要件分析**
   - ユーザーの要望を分析
   - 必要な技術スタックを特定
   - プロジェクト規模を推定

2. **チーム構成決定**
   以下の観点から必要なチームとメンバー数を決定：
   
   ### 基本チーム候補
   - **Frontend Team**: UI/UX、Webアプリ、モバイルアプリが必要な場合
   - **Backend Team**: API、サーバーロジック、認証が必要な場合
   - **Database Team**: データ設計、大規模データ処理が必要な場合
   - **DevOps Team**: インフラ、CI/CD、スケーリングが必要な場合
   - **AI/ML Team**: 機械学習、データ分析、AIが必要な場合
   - **Blockchain Team**: Web3、スマートコントラクト、暗号資産が必要な場合
   - **Mobile Team**: ネイティブアプリ、クロスプラットフォームが必要な場合
   - **Security Team**: 高度なセキュリティ、ペンテストが必要な場合
   - **QA Team**: 品質保証、自動テスト、パフォーマンステストが必要な場合

3. **メンバー数の決定**
   - 小規模機能: 1-2名
   - 中規模機能: 2-3名
   - 大規模機能: 3-4名
   - 超大規模機能: 4-6名

4. **teams.json生成**
   ```json
   {
     "teams": [
       {
         "id": "frontend",
         "name": "Frontend Team",
         "description": "UI/UX開発",
         "member_count": 3,
         "tech_stack": "Next.js 14, React 18, TypeScript",
         "justification": "モダンなWebアプリケーションのため",
         "active": true
       }
     ]
   }
   ```

## 判断基準

### Webアプリケーション
- Frontend Team (2-4名)
- Backend Team (2-3名)
- Database Team (1-2名)
- DevOps Team (1名)

### モバイルアプリ
- Mobile Team (2-3名)
- Backend Team (2-3名)
- DevOps Team (1名)

### AIプロダクト
- AI/ML Team (3-4名)
- Backend Team (2名)
- Database Team (2名)
- Frontend Team (2名)

### ブロックチェーン
- Blockchain Team (3-4名)
- Frontend Team (2名)
- Security Team (2名)

### エンタープライズ
- すべてのチーム（各3-4名）

## 実行コマンド

要件を聞いたら、以下のようにteams.jsonを生成：

```bash
cat > config/teams.json << 'JSON'
{
  "project_name": "プロジェクト名",
  "teams": [
    選択されたチーム構成
  ]
}
JSON

# チーム追加コマンドを実行
./join-company.sh
```

## 重要な原則

1. **最小構成から開始** - 必要最小限のチームで始める
2. **段階的拡張** - プロジェクトの成長に応じてチーム追加
3. **専門性重視** - 各チームに明確な責任範囲
4. **柔軟性維持** - いつでもチーム構成を変更可能

**プロダクトの成功に必要なチームを、過不足なく編成してください。**
EOF
}

# チームテンプレート自動選択
select_team_templates() {
    local product_type="$1"
    local selected_teams=()
    
    case "$product_type" in
        "web-app")
            selected_teams=("frontend" "backend" "database" "devops")
            ;;
        "mobile-app")
            selected_teams=("mobile" "backend" "devops")
            ;;
        "ai-product")
            selected_teams=("ai" "backend" "database" "frontend")
            ;;
        "blockchain")
            selected_teams=("blockchain" "frontend" "security")
            ;;
        "enterprise")
            selected_teams=("frontend" "backend" "database" "devops" "qa-security")
            ;;
        *)
            selected_teams=("frontend" "backend")
            ;;
    esac
    
    echo "${selected_teams[@]}"
}

# 動的チーム構成の検証
validate_team_composition() {
    local teams_json="$1"
    
    # 最低1チーム必要
    local team_count=$(jq '.teams | length' "$teams_json")
    if [ "$team_count" -eq 0 ]; then
        log_error "少なくとも1つのチームが必要です"
        return 1
    fi
    
    # 各チームのメンバー数チェック（1-10名）
    local invalid_count=$(jq '[.teams[].member_count | select(. < 1 or . > 10)] | length' "$teams_json")
    if [ "$invalid_count" -gt 0 ]; then
        log_error "チームメンバー数は1-10名の範囲で設定してください"
        return 1
    fi
    
    return 0
}

# プロジェクトタイプに基づくチームテンプレート生成
generate_team_template() {
    local team_type="$1"
    local member_count="${2:-3}"
    
    case "$team_type" in
        "ai")
            cat << EOF
{
  "id": "ai",
  "name": "AI/ML Team",
  "description": "AI・機械学習開発チーム",
  "tech_stack": "Python, TensorFlow, PyTorch, Transformers, LangChain",
  "member_count": $member_count,
  "branch": "team/ai",
  "active": true,
  "responsibilities": [
    "機械学習モデルの設計・実装",
    "データパイプラインの構築",
    "モデルの最適化とデプロイ",
    "AIサービスのAPI化"
  ]
}
EOF
            ;;
        "blockchain")
            cat << EOF
{
  "id": "blockchain",
  "name": "Blockchain Team",
  "description": "ブロックチェーン・Web3開発チーム",
  "tech_stack": "Solidity, Hardhat, ethers.js, Web3.js, IPFS",
  "member_count": $member_count,
  "branch": "team/blockchain",
  "active": true,
  "responsibilities": [
    "スマートコントラクト開発",
    "DApps実装",
    "ガス最適化",
    "セキュリティ監査"
  ]
}
EOF
            ;;
        "mobile")
            cat << EOF
{
  "id": "mobile",
  "name": "Mobile Team",
  "description": "モバイルアプリ開発チーム",
  "tech_stack": "React Native, Flutter, Swift, Kotlin, Expo",
  "member_count": $member_count,
  "branch": "team/mobile",
  "active": true,
  "responsibilities": [
    "クロスプラットフォームアプリ開発",
    "ネイティブ機能の実装",
    "パフォーマンス最適化",
    "アプリストア対応"
  ]
}
EOF
            ;;
        *)
            # デフォルトのチームテンプレートを返す
            echo "{}"
            ;;
    esac
}

# Masterプロジェクト初期化時の動的チーム生成
initialize_dynamic_project() {
    local project_description="$1"
    
    log_info "プロジェクト初期化: 動的チーム構成を生成中..."
    
    # Masterへのプロンプト生成
    generate_master_dynamic_prompt > "$WORKSPACE/CLAUDE_MASTER_DYNAMIC.md"
    
    # プロジェクト説明をファイルに保存
    cat > "$WORKSPACE/PROJECT_REQUIREMENTS.md" << EOF
# プロジェクト要件

$project_description

## 作成日時
$(date '+%Y-%m-%d %H:%M:%S')
EOF
    
    log_success "動的チーム構成の準備が完了しました"
    log_info "Masterが要件を分析してチーム構成を決定します"
}

# チーム追加/削除の動的管理
update_team_composition() {
    local action="$1"  # add or remove
    local team_id="$2"
    local member_count="${3:-3}"
    
    if [ "$action" = "add" ]; then
        log_info "チーム追加: $team_id (メンバー数: $member_count)"
        # teams.jsonを更新
        local temp_file=$(mktemp)
        jq ".teams += [{\"id\": \"$team_id\", \"member_count\": $member_count, \"active\": true}]" \
            "$WORKSPACE/config/teams.json" > "$temp_file"
        mv "$temp_file" "$WORKSPACE/config/teams.json"
    elif [ "$action" = "remove" ]; then
        log_info "チーム削除: $team_id"
        # teams.jsonを更新
        local temp_file=$(mktemp)
        jq ".teams = [.teams[] | select(.id != \"$team_id\")]" \
            "$WORKSPACE/config/teams.json" > "$temp_file"
        mv "$temp_file" "$WORKSPACE/config/teams.json"
    fi
}