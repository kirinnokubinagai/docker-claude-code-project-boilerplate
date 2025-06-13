#!/usr/bin/fish

# Master Claude Teams System - Fish版
# 動的チーム管理システム

# カラー定義（Fishシェル用）
set -g RED (set_color red 2>/dev/null; or echo "")
set -g GREEN (set_color green 2>/dev/null; or echo "")
set -g YELLOW (set_color yellow 2>/dev/null; or echo "")
set -g BLUE (set_color blue 2>/dev/null; or echo "")
set -g PURPLE (set_color purple 2>/dev/null; or echo "")
set -g CYAN (set_color cyan 2>/dev/null; or echo "")
set -g BOLD (set_color --bold 2>/dev/null; or echo "")
set -g NC (set_color normal 2>/dev/null; or echo "")

# 設定
set -g SESSION_NAME claude-teams
set -g WORKSPACE /workspace
set -g WORKTREES_DIR $WORKSPACE/worktrees
set -g CLAUDE_CMD 'claude --dangerously-skip-permissions'
set -g CLAUDE_STARTUP_WAIT 5
set -g INITIAL_MESSAGE_WAIT 3
set -g TEAMS_CONFIG_FILE $WORKSPACE/config/teams.json
set -g TEAM_TASKS_FILE $WORKSPACE/config/team-tasks.json
set -g MESSAGE_QUEUE_DIR $WORKSPACE/.messages
set -g WORKFLOW_STATE_FILE $WORKSPACE/.workflow_state.json

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

function show_banner
    printf "%s%s\n" $CYAN $BOLD
    echo "======================================"
    echo " $argv[1]"
    if test (count $argv) -ge 2
        echo " $argv[2]"
    end
    echo "======================================"
    printf "%s\n" $NC
end

# 依存関係チェック
function check_dependencies
    set -l missing
    
    for cmd in $argv
        if not command -v $cmd >/dev/null 2>&1
            set -a missing $cmd
        end
    end
    
    if test (count $missing) -gt 0
        log_error "必要なコマンドがインストールされていません: $missing"
        return 1
    end
    return 0
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

# Git初期化
function init_git_repo
    cd $argv[1]
    or return 1
    
    if not test -d .git
        git init
        git add .
        git commit -m "Initial commit" --allow-empty
    end
    
    if not git rev-parse HEAD >/dev/null 2>&1
        git add .
        git commit -m "Initial commit" --allow-empty
    end
end

# メッセージキュー初期化
function init_message_queue
    ensure_directory $MESSAGE_QUEUE_DIR
    # ワイルドカードがマッチしない場合のエラーを回避
    set -l msg_files $MESSAGE_QUEUE_DIR/*.msg
    if test (count $msg_files) -gt 0
        rm -f $msg_files
    end
    log_success "メッセージキューを初期化しました"
end

# tmuxセッションをkill
function kill_tmux_session
    if tmux has-session -t $argv[1] 2>/dev/null
        log_info "既存のtmuxセッション削除: $argv[1]"
        tmux kill-session -t $argv[1]
    end
end

# worktreeセットアップ
function setup_worktrees
    log_info "各チーム用のworktreeを作成中..."
    
    cd $WORKSPACE
    or begin
        log_error "ワークスペースディレクトリにアクセスできません: $WORKSPACE"
        return 1
    end
    
    if not test -d .git
        log_error "Gitリポジトリが初期化されていません"
        return 1
    end
    
    # 既存のworktreeをクリーンアップ
    git worktree prune -v
    
    # teams.jsonからアクティブなチームを取得
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE)
        
        for team in $teams
            set -l branch (jq -r ".teams[] | select(.id == \"$team\") | .branch" $TEAMS_CONFIG_FILE)
            set -l worktree_path $WORKTREES_DIR/$team
            
            # ブランチが存在しない場合は作成
            if not git show-ref --verify --quiet refs/heads/$branch
                git checkout -b $branch
                git checkout main
            end
            
            # worktreeを作成
            if not test -d $worktree_path
                log_info "worktree作成: $team -> $branch"
                git worktree add $worktree_path $branch
                or begin
                    log_error "worktreeの作成に失敗しました: $team"
                    continue
                end
            end
        end
    end
    
    log_success "worktreeのセットアップが完了しました"
end

# tmuxレイアウト作成
function create_tmux_layout
    log_info "動的チーム構成のtmuxセッションを構築中..."
    
    # 新しいセッションを作成（全員が同じウィンドウ）
    tmux new-session -d -s $SESSION_NAME -n "All-Teams" -c $WORKSPACE
    
    # まずMasterのペインを作成（ペイン0）
    # set-pane-border-formatは古いtmuxでは使えないのでコメントアウト
    # tmux set-pane-border-format "#{pane_index}: Master"
    
    # 総メンバー数を計算
    set -l total_members 1  # Master分
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE)
        
        for team in $teams
            set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 4" $TEAMS_CONFIG_FILE)
            set total_members (math $total_members + $member_count)
        end
    end
    
    log_info "総メンバー数: $total_members 人"
    
    # アクティブなチームのペインを作成
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE)
        set -l pane_index 1
        
        for team in $teams
            set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE)
            set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 4" $TEAMS_CONFIG_FILE)
            set -l worktree_path $WORKTREES_DIR/$team
            
            log_info "チームペイン作成: $team_name ($member_count 人)"
            
            # 各メンバー用のペインを作成
            for member in (seq 1 $member_count)
                # 新しいペインを作成
                if test $total_members -le 2
                    # 2人以下: 左右分割
                    tmux split-window -t $SESSION_NAME:0 -h -c $worktree_path
                else if test $total_members -le 4
                    # 3-4人: 田の字型
                    if test $pane_index -eq 1
                        tmux split-window -t $SESSION_NAME:0 -h -c $worktree_path
                    else if test $pane_index -eq 2
                        tmux split-window -t $SESSION_NAME:0 -v -c $worktree_path
                    else
                        tmux split-window -t $SESSION_NAME:0.1 -v -c $worktree_path
                    end
                else
                    # 5人以上: tiled レイアウトを使用
                    tmux split-window -t $SESSION_NAME:0 -c $worktree_path
                end
                
                # ペインのタイトルを設定
                tmux select-pane -t $SESSION_NAME:0.$pane_index -T "$team-$member"
                
                set pane_index (math $pane_index + 1)
            end
        end
        
        # レイアウトを自動調整
        if test $total_members -gt 4
            tmux select-layout -t $SESSION_NAME:0 tiled
        else if test $total_members -eq 3
            tmux select-layout -t $SESSION_NAME:0 main-vertical
        end
    end
    
    # 各ペインのボーダーにタイトルを表示
    tmux set-option -t $SESSION_NAME pane-border-status top
    tmux set-option -t $SESSION_NAME pane-border-format "#{pane_index}: #{pane_title}"
    
    log_success "動的チーム構成のtmuxレイアウトを作成しました（1ウィンドウ）"
end

# 設定ファイル作成
function create_team_configurations
    log_info "設定ファイルを作成中..."
    
    # Master設定を作成
    log_info "Master設定を作成中..."
    set -l master_config "$WORKSPACE/CLAUDE_MASTER.md"
    
    echo "# Master Claude - 全体統括

あなたはMaster Claudeとして、プロジェクト全体を統括します。

## 役割
- 各チームの進捗管理
- チーム間の調整
- 全体的な技術判断
- コードレビューの最終確認

## 現在のチーム構成" > $master_config
    
    if test -f $TEAMS_CONFIG_FILE
        jq -r '.teams[] | select(.active == true) | "- \(.name): \(.description)"' $TEAMS_CONFIG_FILE >> $master_config
    end
    
    log_success "全ての設定ファイルを作成しました"
end

# 全チーム起動
function launch_all_teams
    log_info "Claude Codeを起動中..."
    
    # 全ペインでClaude Codeを起動
    set -l total_panes (tmux list-panes -t $SESSION_NAME:0 -F "#{pane_index}" 2>/dev/null | wc -l | string trim)
    log_info "総ペイン数: $total_panes"
    
    # 各ペインでClaude Codeを起動
    for pane_index in (seq 0 (math $total_panes - 1))
        if test $pane_index -eq 0
            log_info "Master起動中 (ペイン $pane_index)..."
        else
            # チーム情報を取得してログ出力
            set -l pane_title (tmux display-message -t $SESSION_NAME:0.$pane_index -p '#{pane_title}' 2>/dev/null || echo "")
            log_info "起動中: ペイン $pane_index ($pane_title)..."
        end
        
        tmux send-keys -t $SESSION_NAME:0.$pane_index "$CLAUDE_CMD" Enter
        sleep 0.5  # 各ペインの起動を少し遅延
    end
    
    # 初期化待機
    log_info "初期化待機中..."
    sleep $CLAUDE_STARTUP_WAIT
    
    # 各ペインに初期メッセージを送信
    if test -f $TEAM_TASKS_FILE
        log_info "初期タスクメッセージを送信中..."
        
        # Masterペインに初期メッセージを送信
        set -l master_prompt (jq -r '.master.initial_prompt' $TEAM_TASKS_FILE)
        if test -n "$master_prompt"
            log_info "Master初期メッセージ送信..."
            # エスケープ処理と改行対応
            set -l escaped_prompt (echo "$master_prompt" | sed 's/"/\\"/g' | tr '\n' ' ')
            tmux send-keys -t $SESSION_NAME:0.0 "$escaped_prompt" Enter
        end
        
        # 各チームメンバーに初期メッセージを送信
        set -l pane_index 1
        if test -f $TEAMS_CONFIG_FILE
            set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE)
            
            for team in $teams
                set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 4" $TEAMS_CONFIG_FILE)
                
                for member in (seq 1 $member_count)
                    # タスクファイルから該当メンバーの初期プロンプトを取得
                    set -l member_prompt (jq -r ".\"$team\".member_tasks[] | select(.member_id == $member) | .initial_prompt" $TEAM_TASKS_FILE)
                    
                    if test -n "$member_prompt"
                        log_info "送信: ペイン $pane_index ($team-member$member)"
                        # エスケープ処理と改行対応
                        set -l escaped_prompt (echo "$member_prompt" | sed 's/"/\\"/g' | tr '\n' ' ')
                        tmux send-keys -t $SESSION_NAME:0.$pane_index "$escaped_prompt" Enter
                    end
                    
                    set pane_index (math $pane_index + 1)
                    sleep 0.3  # 各メッセージ送信間に少し遅延
                end
            end
        end
        
        sleep $INITIAL_MESSAGE_WAIT
    end
    
    log_success "起動が完了しました"
end

# クリーンアップ
function cleanup
    log_warning "クリーンアップを実行中..."
    kill_tmux_session $SESSION_NAME
    log_info "クリーンアップ完了"
end

# メイン処理
function main
    # バナー表示
    show_banner "Master Claude Teams System v4.0" "動的チーム管理 (Fish版)"
    
    # 依存関係チェック
    check_dependencies tmux claude git jq
    or exit 1
    
    # ディレクトリ作成
    ensure_directory $WORKTREES_DIR
    
    # Git初期化
    init_git_repo $WORKSPACE
    or exit 1
    
    # メッセージキューの初期化
    init_message_queue
    
    # 既存セッションのクリーンアップ
    kill_tmux_session $SESSION_NAME
    
    # メイン処理の実行
    setup_worktrees
    or exit 1
    
    create_tmux_layout
    or exit 1
    
    create_team_configurations
    or exit 1
    
    launch_all_teams
    or exit 1
    
    # 使用方法の表示
    log_info "システムの準備が完了しました！"
    echo ""
    
    if test -f $TEAMS_CONFIG_FILE; and test (jq -r '.teams | length' $TEAMS_CONFIG_FILE) -gt 0
        set -l active_teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE)
        if test (count $active_teams) -gt 0
            log_info "チーム構成:"
            echo "  - Master: 1人（全体統括）"
            jq -r '.teams[] | select(.active == true) | "  - \(.name): \(.member_count // 4)人"' $TEAMS_CONFIG_FILE
        else
            log_info "Masterのみで起動中"
            echo "  - Master: 1人（全体統括）"
        end
    end
    
    echo ""
    log_info "tmuxコマンド:"
    echo "  - Ctrl+a → 矢印: ペイン間移動"
    echo "  - Ctrl+a → z: ペイン最大化/復元"
    echo "  - Ctrl+a → スペース: レイアウト変更"
    echo "  - Ctrl+a → o: 次のペインへ移動"
    echo "  - Ctrl+a → ;: 前のペインへ戻る"
    echo ""
    
    log_success "セッションにアタッチします..."
    sleep 2
    
    # セッションにアタッチ
    tmux attach-session -t $SESSION_NAME
end

# トラップ設定
trap cleanup SIGINT SIGTERM

# エントリーポイント
main $argv