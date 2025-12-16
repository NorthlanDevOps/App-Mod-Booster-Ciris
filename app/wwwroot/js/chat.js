// Chat functionality
const chatMessages = document.getElementById('chat-messages');
const chatInput = document.getElementById('chat-input');
const sendButton = document.getElementById('send-button');

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatMessage(text) {
    // Escape HTML first
    let formatted = escapeHtml(text);
    
    // Convert **text** to <strong>text</strong>
    formatted = formatted.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    
    // Convert numbered lists
    const lines = formatted.split('\n');
    let inOrderedList = false;
    let inUnorderedList = false;
    let result = [];
    
    for (let line of lines) {
        const trimmed = line.trim();
        
        // Numbered list
        if (/^\d+\.\s/.test(trimmed)) {
            if (!inOrderedList) {
                result.push('<ol>');
                inOrderedList = true;
            }
            result.push('<li>' + trimmed.replace(/^\d+\.\s/, '') + '</li>');
        }
        // Bullet list
        else if (/^[-*]\s/.test(trimmed)) {
            if (!inUnorderedList) {
                result.push('<ul>');
                inUnorderedList = true;
            }
            result.push('<li>' + trimmed.replace(/^[-*]\s/, '') + '</li>');
        }
        // Normal line
        else {
            if (inOrderedList) {
                result.push('</ol>');
                inOrderedList = false;
            }
            if (inUnorderedList) {
                result.push('</ul>');
                inUnorderedList = false;
            }
            if (trimmed) {
                result.push(line + '<br>');
            }
        }
    }
    
    // Close any open lists
    if (inOrderedList) result.push('</ol>');
    if (inUnorderedList) result.push('</ul>');
    
    return result.join('');
}

function addMessage(text, isUser) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `chat-message ${isUser ? 'user' : 'assistant'}`;
    
    if (isUser) {
        messageDiv.textContent = text;
    } else {
        messageDiv.innerHTML = formatMessage(text);
    }
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

async function sendMessage() {
    const message = chatInput.value.trim();
    if (!message) return;
    
    addMessage(message, true);
    chatInput.value = '';
    sendButton.disabled = true;
    
    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ message: message }),
        });
        
        const data = await response.json();
        addMessage(data.message, false);
    } catch (error) {
        addMessage('Error: Unable to get response. ' + error.message, false);
    } finally {
        sendButton.disabled = false;
    }
}

sendButton.addEventListener('click', sendMessage);
chatInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        sendMessage();
    }
});

// Add welcome message
addMessage('Hello! I can help you find information about properties, sections, workbases, and users. What would you like to know?', false);
