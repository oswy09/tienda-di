<template>
  <footer class="footer">
    <div class="footer-content">
      <div class="info-section">
        <div class="info-item">
          <div class="icon">✈️</div>
          <h3>Envíos a nivel nacional</h3>
          <p>Entregamos en todo el país de forma rápida y segura.</p>
        </div>
        <div class="info-item">
          <div class="icon">🔒</div>
          <h3>Compra 100% segura</h3>
          <p>Confianza y respaldo en cada compra que realizas.</p>
        </div>
        <div class="info-item">
          <div class="icon">💬</div>
          <h3>Asesoría personalizada</h3>
          <p>Resuelve tus dudas y encuentra lo que buscas.</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2024 STYLE STORE - Todos los derechos reservados</p>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  background: #000;
  color: #fff;
  border-top: 4px solid #fff;
  margin-top: 60px;
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 60px 20px 30px;
}

.info-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 40px;
  margin-bottom: 50px;
}

.info-item {
  text-align: center;
}

.icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.info-item h3 {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 1px;
  margin: 0 0 12px 0;
  text-transform: uppercase;
}

.info-item p {
  font-size: 14px;
  line-height: 1.6;
  color: #ccc;
  margin: 0;
  font-weight: 400;
}

.footer-bottom {
  text-align: center;
  padding-top: 30px;
  border-top: 1px solid #333;
}

.footer-bottom p {
  margin: 0;
  font-size: 13px;
  color: #999;
  letter-spacing: 0.5px;
}

@media (max-width: 768px) {
  .footer-content {
    padding: 40px 20px 20px;
  }

  .info-section {
    gap: 32px;
    margin-bottom: 40px;
  }

  .icon {
    font-size: 40px;
  }

  .info-item h3 {
    font-size: 14px;
  }

  .info-item p {
    font-size: 13px;
  }
}
</style>
