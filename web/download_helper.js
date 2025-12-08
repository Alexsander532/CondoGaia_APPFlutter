// web/download_helper.js
function downloadFile(base64Data, filename, mimeType) {
  try {
    // Converte base64 para binary string
    const binaryString = atob(base64Data);
    const bytes = new Uint8Array(binaryString.length);
    
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    
    // Cria um blob a partir dos bytes
    const blob = new Blob([bytes], { type: mimeType });
    
    // Cria um URL para o blob
    const url = URL.createObjectURL(blob);
    
    // Cria um elemento <a> temporário
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    
    // Adiciona ao DOM, clica e remove
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Libera a memória
    URL.revokeObjectURL(url);
    
    return true;
  } catch (error) {
    console.error('Erro ao fazer download:', error);
    return false;
  }
}
