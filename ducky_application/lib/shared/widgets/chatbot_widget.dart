import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, {required this.isUser});
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  bool _isOpen = false;
  final _textCtrl = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage('¡Hola! Soy el patito bibliotecario 🦆. Pregúntame sobre horarios, multas o préstamos.', isUser: false),
  ];
  final _scrollCtrl = ScrollController();
  static const _green = Color(0xFF0E7334);

  void _toggleChat() {
    setState(() => _isOpen = !_isOpen);
  }

  void _handleSend() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text, isUser: true));
      _textCtrl.clear();
    });
    
    _scrollToBottom();
    
    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(_generateResponse(text.toLowerCase()), isUser: false));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateResponse(String q) {
    if (q.contains('hola') || q.contains('buen') || q.contains('salud')) {
      return '¡Hola! ¿En qué te puedo ayudar hoy?';
    }
    if (q.contains('horario') || q.contains('hora') || q.contains('abiert')) {
      return 'La biblioteca está abierta de Lunes a Viernes de 8:00 AM a 8:00 PM, y los Sábados de 9:00 AM a 2:00 PM.';
    }
    if (q.contains('multa') || q.contains('pagar') || q.contains('costo') || q.contains('retraso')) {
      return 'Las multas por retraso son de \$10.00 pesos por día hábil. Si dañas o pierdes un libro, la multa es igual al costo completo de recuperación del libro.';
    }
    if (q.contains('prestamo') || q.contains('libro') || q.contains('tiempo')) {
      return 'Puedes llevarte a casa los libros de catálogo normal por 5 días hábiles. Recuerda traer tu credencial para solicitarlos.';
    }
    if (q.contains('renovar') || q.contains('renovacion')) {
      return 'Puedes renovar un libro desde tu panel hasta 2 veces, lo que te dará 14 días adicionales cada vez. Sólo no aplica si tienes multas pendientes o alguien más ya lo reservó.';
    }
    return '¡Cuac! 🦆 No estoy muy seguro de entender eso. Intenta preguntarme sobre el horario, multas, o reglas de préstamo.';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) {
      return FloatingActionButton(
        onPressed: _toggleChat,
        backgroundColor: _green,
        elevation: 4,
        child: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 28),
      );
    }

    return Container(
      width: 320,
      height: 480,
      margin: const EdgeInsets.only(bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 16,
                  child: Text('🦆', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asistente Ducky', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('En línea', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                  onPressed: _toggleChat,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
          
          // Chat Area
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final m = _messages[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!m.isUser) ...[
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE5E7EB),
                            radius: 12,
                            child: Text('🦆', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: m.isUser ? _green : Colors.white,
                              borderRadius: BorderRadius.circular(12).copyWith(
                                bottomRight: m.isUser ? const Radius.circular(0) : null,
                                bottomLeft: !m.isUser ? const Radius.circular(0) : null,
                              ),
                              border: m.isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: m.isUser ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    onSubmitted: (_) => _handleSend(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.send, color: Colors.white, size: 16),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
