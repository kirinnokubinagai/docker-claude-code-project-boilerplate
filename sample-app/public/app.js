const todoInput = document.getElementById('todoInput');
const addBtn = document.getElementById('addBtn');
const todoList = document.getElementById('todoList');

// Load todos on page load
loadTodos();

// Event listeners
addBtn.addEventListener('click', addTodo);
todoInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    addTodo();
  }
});

async function loadTodos() {
  try {
    const response = await fetch('/api/todos');
    const todos = await response.json();
    renderTodos(todos);
  } catch (error) {
    console.error('Error loading todos:', error);
  }
}

async function addTodo() {
  const text = todoInput.value.trim();
  if (!text) return;
  
  try {
    const response = await fetch('/api/todos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ text })
    });
    
    if (response.ok) {
      todoInput.value = '';
      loadTodos();
    }
  } catch (error) {
    console.error('Error adding todo:', error);
  }
}

async function toggleTodo(id, completed) {
  try {
    const response = await fetch(`/api/todos/${id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ completed })
    });
    
    if (response.ok) {
      loadTodos();
    }
  } catch (error) {
    console.error('Error updating todo:', error);
  }
}

async function deleteTodo(id) {
  try {
    const response = await fetch(`/api/todos/${id}`, {
      method: 'DELETE'
    });
    
    if (response.ok) {
      loadTodos();
    }
  } catch (error) {
    console.error('Error deleting todo:', error);
  }
}

function renderTodos(todos) {
  todoList.innerHTML = '';
  
  todos.forEach(todo => {
    const li = document.createElement('li');
    li.className = `todo-item ${todo.completed ? 'completed' : ''}`;
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.className = 'todo-checkbox';
    checkbox.checked = todo.completed;
    checkbox.addEventListener('change', () => toggleTodo(todo.id, checkbox.checked));
    
    const text = document.createElement('span');
    text.className = 'todo-text';
    text.textContent = todo.text;
    
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-btn';
    deleteBtn.textContent = '削除';
    deleteBtn.addEventListener('click', () => deleteTodo(todo.id));
    
    li.appendChild(checkbox);
    li.appendChild(text);
    li.appendChild(deleteBtn);
    
    todoList.appendChild(li);
  });
}