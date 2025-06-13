#!/usr/bin/fish

# Join Company - 動的チーム構成スクリプト（Fish版）
# プロジェクトの要件に基づいて最適なチーム構成を自動生成

# スクリプトのディレクトリを取得
set SCRIPT_DIR (dirname (status --current-filename))
set WORKSPACE $SCRIPT_DIR

# ライブラリのパスを設定
set LIB_DIR $SCRIPT_DIR/lib

# 設定ファイル
set TEAMS_CONFIG_FILE $WORKSPACE/config/teams.json
set TEAM_TEMPLATES_DIR $WORKSPACE/team-templates

# カラー定義（Fishシェル用）
set -g GREEN (set_color green)
set -g YELLOW (set_color yellow)
set -g BLUE (set_color blue)
set -g RED (set_color red)
set -g NC (set_color normal)

# ログ関数
function log_info
    printf "%s[INFO]%s %s\n" $BLUE $NC "$argv"
end

function log_success
    printf "%s[SUCCESS]%s %s\n" $GREEN $NC "$argv"
end

function log_warning
    printf "%s[WARNING]%s %s\n" $YELLOW $NC "$argv"
end

function log_error
    printf "%s[ERROR]%s %s\n" $RED $NC "$argv"
end

# ディレクトリ作成
function ensure_directory
    if not test -d $argv[1]
        mkdir -p $argv[1]
        or begin
            log_error "ディレクトリの作成に失敗しました: $argv[1]"
            return 1
        end
    end
end

# プロジェクト分析
function analyze_project_requirements
    log_info "プロジェクト要件を分析中..."
    
    # プロジェクトファイルの存在確認
    set -l has_frontend false
    set -l has_backend false
    set -l has_mobile false
    set -l has_database false
    set -l project_size "small"
    
    # フロントエンド判定
    if test -f package.json
        and grep -qE "(react|vue|angular|next|nuxt|svelte)" package.json 2>/dev/null
        set has_frontend true
    end
    
    # バックエンド判定
    if test -f package.json
        and grep -qE "(express|fastify|nestjs|koa)" package.json 2>/dev/null
        set has_backend true
    end
    
    # モバイル判定
    if test -f package.json
        and grep -qE "(react-native|expo|ionic)" package.json 2>/dev/null
        set has_mobile true
    end
    
    # データベース判定
    if test -f docker-compose.yml
        and grep -qE "(postgres|mysql|mongodb|redis)" docker-compose.yml 2>/dev/null
        set has_database true
    end
    
    # プロジェクトサイズ判定
    set -l file_count (find . -type f -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null | wc -l)
    if test $file_count -gt 100
        set project_size "large"
    else if test $file_count -gt 20
        set project_size "medium"
    end
    
    echo "$has_frontend|$has_backend|$has_mobile|$has_database|$project_size"
end

# 動的チーム構成生成
function generate_dynamic_team_config
    set -l analysis (analyze_project_requirements)
    set -l parts (string split "|" $analysis)
    set -l has_frontend $parts[1]
    set -l has_backend $parts[2]
    set -l has_mobile $parts[3]
    set -l has_database $parts[4]
    set -l project_size $parts[5]
    
    log_info "プロジェクト分析結果:"
    log_info "  - フロントエンド: $has_frontend"
    log_info "  - バックエンド: $has_backend"
    log_info "  - モバイル: $has_mobile"
    log_info "  - データベース: $has_database"
    log_info "  - プロジェクトサイズ: $project_size"
    
    # チーム構成を決定
    set -l teams '{"teams": ['
    set -l team_count 0
    
    # フロントエンドチーム
    if test $has_frontend = "true"
        if test $team_count -gt 0
            set teams "$teams,"
        end
        set -l member_count 2
        if test $project_size = "large"
            set member_count 4
        else if test $project_size = "medium"
            set member_count 3
        end
        set teams "$teams"'{"id": "frontend", "name": "Frontend Team", "description": "UI/UX開発", "member_count": '$member_count', "tech_stack": "Next.js", "branch": "team/frontend", "active": true}'
        set team_count (math $team_count + 1)
    end
    
    # バックエンドチーム
    if test $has_backend = "true"
        if test $team_count -gt 0
            set teams "$teams,"
        end
        set -l member_count 2
        if test $project_size = "large"
            set member_count 4
        else if test $project_size = "medium"
            set member_count 3
        end
        set teams "$teams"'{"id": "backend", "name": "Backend Team", "description": "API開発", "member_count": '$member_count', "tech_stack": "Node.js", "branch": "team/backend", "active": true}'
        set team_count (math $team_count + 1)
    end
    
    # モバイルチーム
    if test $has_mobile = "true"
        if test $team_count -gt 0
            set teams "$teams,"
        end
        set teams "$teams"'{"id": "mobile", "name": "Mobile Team", "description": "モバイルアプリ開発", "member_count": 2, "tech_stack": "React Native", "branch": "team/mobile", "active": true}'
        set team_count (math $team_count + 1)
    end
    
    # データベースチーム（大規模プロジェクトのみ）
    if test $has_database = "true" -a $project_size = "large"
        if test $team_count -gt 0
            set teams "$teams,"
        end
        set teams "$teams"'{"id": "database", "name": "Database Team", "description": "データベース設計・最適化", "member_count": 2, "tech_stack": "PostgreSQL", "branch": "team/database", "active": true}'
        set team_count (math $team_count + 1)
    end
    
    # QA/セキュリティチーム（中規模以上）
    if test $project_size != "small"
        if test $team_count -gt 0
            set teams "$teams,"
        end
        set teams "$teams"'{"id": "qa-security", "name": "QA & Security Team", "description": "品質保証とセキュリティ", "member_count": 2, "tech_stack": "Testing/Security", "branch": "team/qa-security", "active": true}'
        set team_count (math $team_count + 1)
    end
    
    set teams "$teams]}"
    
    echo $teams
end

# テンプレートからチーム構成を読み込み
function load_team_template
    set -l template_name $argv[1]
    set -l template_file "$TEAM_TEMPLATES_DIR/$template_name.json"
    
    if not test -f $template_file
        log_error "テンプレートが見つかりません: $template_name"
        return 1
    end
    
    cat $template_file
end

# メイン処理
function main
    log_info "動的チーム構成システムを起動..."
    
    # 設定ディレクトリを作成
    ensure_directory (dirname $TEAMS_CONFIG_FILE)
    
    # 引数処理
    if test (count $argv) -eq 0
        # 動的構成をデフォルトに
        set argv --dynamic
    end
    
    set -l config_json ""
    
    switch $argv[1]
        case --dynamic
            log_info "プロジェクトに最適なチーム構成を自動生成中..."
            set config_json (generate_dynamic_team_config)
            
        case --list
            log_info "利用可能なテンプレート:"
            for template in $TEAM_TEMPLATES_DIR/*.json
                set -l name (basename $template .json)
                echo "  - $name"
            end
            return 0
            
        case '*'
            log_info "テンプレートを読み込み中: $argv[1]"
            set config_json (load_team_template $argv[1])
            or return 1
    end
    
    # 設定ファイルに保存
    echo $config_json > $TEAMS_CONFIG_FILE
    
    # プロジェクトタイプを検出してタスクを生成
    set -l project_type "web"  # デフォルト
    set -l project_name (basename $WORKSPACE)
    
    # package.jsonやその他のファイルからプロジェクトタイプを推測
    if test -f $WORKSPACE/package.json
        if grep -q '"react-native"' $WORKSPACE/package.json 2>/dev/null
            set project_type "mobile"
        else if grep -q '"@nestjs/core"' $WORKSPACE/package.json 2>/dev/null
            set project_type "api"
        else if grep -q '"next"' $WORKSPACE/package.json 2>/dev/null
            set project_type "web"
        end
    end
    
    # タスクファイルを生成
    if test -x $WORKSPACE/lib/generate-team-tasks.sh
        log_info "プロジェクトタイプ '$project_type' のタスクを生成中..."
        $WORKSPACE/lib/generate-team-tasks.sh $project_type $project_name
    end
    
    # 結果を表示
    log_success "チーム構成を作成しました！"
    echo ""
    log_info "チーム構成:"
    jq -r '.teams[] | "  - \(.name) (\(.member_count)人): \(.description)"' $TEAMS_CONFIG_FILE
    echo ""
    
    # 次のステップを案内
    log_info "次のステップ:"
    echo "  1. 'master' コマンドでシステムを起動"
    echo "  2. 各チームが自動的に配置されます"
    echo ""
end

# エントリーポイント
main $argv