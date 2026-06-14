require 'tk'

class DataStructureVisualizer
  def initialize
    @root = TkRoot.new { title "スタック & キュー 可視化アプリ" }
    @root.geometry("800x500")

    # データ格納用配列
    @stack_data = []
    @queue_data = []
    
    # 描画用サイズ設定
    @box_width = 60
    @box_height = 40
    @start_y = 100

    create_widgets
    draw_all
  end

  def create_widgets
    # --- 操作パネル (上部) ---
    control_frame = TkFrame.new(@root).pack(side: 'top', fill: 'x', padx: 10, pady: 10)

    TkLabel.new(control_frame, text: "値入力:").pack(side: 'left', padx: 5)
    @entry = TkEntry.new(control_frame, width: 10).pack(side: 'left', padx: 5)
    @entry.insert(0, "A") # 初期値

    # スタック操作ボタン
    TkButton.new(control_frame, text: "Stack Push (挿入)", command: proc { push_stack }).pack(side: 'left', padx: 5)
    TkButton.new(control_frame, text: "Stack Pop (取り出し)", command: proc { pop_stack }).pack(side: 'left', padx: 5)

    # セパレーター代わり
    TkLabel.new(control_frame, text: " | ").pack(side: 'left', padx: 10)

    # キュー操作ボタン
    TkButton.new(control_frame, text: "Queue Enqueue (挿入)", command: proc { enqueue_queue }).pack(side: 'left', padx: 5)
    TkButton.new(control_frame, text: "Queue Dequeue (取り出し)", command: proc { dequeue_queue }).pack(side: 'left', padx: 5)

    # --- キャンバス領域 (下部) ---
    @canvas = TkCanvas.new(@root, bg: 'white').pack(side: 'bottom', fill: 'both', expand: true)
  end

  # --- 描画処理 ---
  def draw_all(highlight_idx = nil, type = nil)
    @canvas.delete('all')

    # 1. スタックの描画 (LIFO: 上に積み上がる、または右に伸びる。ここでは右方向に並べます)
    @canvas.create(TkcText, 50, @start_y, text: "スタック\n(Stack)\nLIFO", font: "Helvetica 12 bold", justify: "center")
    @stack_data.each_with_index do |val, idx|
      x1 = 150 + (idx * (@box_width + 10))
      y1 = @start_y - (@box_height / 2)
      x2 = x1 + @box_width
      y2 = y1 + @box_height

      # ポップされる要素（最後の要素）をハイライト
      color = (type == :stack && idx == highlight_idx) ? 'coral' : 'lightblue'
      
      @canvas.create(TkcRectangle, x1, y1, x2, y2, fill: color, outline: 'black', width: 2)
      @canvas.create(TkcText, x1 + (@box_width/2), y1 + (@box_height/2), text: val, font: "Helvetica 12 bold")
      
      # インデックス番号
      @canvas.create(TkcText, x1 + (@box_width/2), y2 + 12, text: "[#{idx}]", fill: 'gray')
    end
    # スタックの入り口・出口の目印
    if @stack_data.any?
      arrow_x = 150 + (@stack_data.size * (@box_width + 10)) - 5
      @canvas.create(TkcText, arrow_x + 20, @start_y, text: "← Push / Pop\n(末尾)", fill: 'darkred')
    end

    # 2. キューの描画 (FIFO: 横に並び、先頭から出ていく)
    queue_y = @start_y + 180
    @canvas.create(TkcText, 50, queue_y, text: "キュー\n(Queue)\nFIFO", font: "Helvetica 12 bold", justify: "center")
    @queue_data.each_with_index do |val, idx|
      x1 = 150 + (idx * (@box_width + 10))
      y1 = queue_y - (@box_height / 2)
      x2 = x1 + @box_width
      y2 = y1 + @box_height

      # デキューされる要素（先頭の要素）をハイライト
      color = (type == :queue && idx == highlight_idx) ? 'lightgreen' : 'lightyellow'

      @canvas.create(TkcRectangle, x1, y1, x2, y2, fill: color, outline: 'black', width: 2)
      @canvas.create(TkcText, x1 + (@box_width/2), y1 + (@box_height/2), text: val, font: "Helvetica 12 bold")
      
      # インデックス番号
      @canvas.create(TkcText, x1 + (@box_width/2), y2 + 12, text: "[#{idx}]", fill: 'gray')
    end
    # キューの入り口・出口の目印
    if @queue_data.any?
      @canvas.create(TkcText, 150 - 30, queue_y, text: "← Dequeue\n(先頭)", fill: 'darkgreen')
      arrow_x_in = 150 + (@queue_data.size * (@box_width + 10)) - 5
      @canvas.create(TkcText, arrow_x_in + 30, queue_y, text: "← Enqueue\n(末尾)", fill: 'darkblue')
    end
  end

  # --- スタックのロジック ---
  def push_stack
    val = @entry.get.strip
    return if val.empty?
    @stack_data << val
    draw_all
    auto_increment_entry
  end

  def pop_stack
    return if @stack_data.empty?
    # 最後の要素（Pop対象）をハイライトしてから削除するアニメーション風演出
    target_idx = @stack_data.size - 1
    draw_all(target_idx, :stack)
    
    Tk.after(300) do
      @stack_data.pop
      draw_all
    end
  end

  # --- キューのロジック ---
  def enqueue_queue
    val = @entry.get.strip
    return if val.empty?
    @queue_data << val
    draw_all
    auto_increment_entry
  end

  def dequeue_queue
    return if @queue_data.empty?
    # 先頭の要素（Dequeue対象）をハイライトしてから削除
    draw_all(0, :queue)

    Tk.after(300) do
      @queue_data.shift
      draw_all
    end
  end

  # 入力欄の文字を自動で次のアルファベットに進める便利機能
  def auto_increment_entry
    current = @entry.get.strip
    if current =~ /^[A-Z]$/
      next_char = (current.ord + 1).chr
      next_char = "A" if next_char > "Z"
      @entry.delete(0, 'end')
      @entry.insert(0, next_char)
    elsif current =~ /^\d+$/
      @entry.delete(0, 'end')
      @entry.insert(0, (current.to_i + 1).to_s)
    end
  end
end

# アプリケーションの起動
DataStructureVisualizer.new
Tk.mainloop
