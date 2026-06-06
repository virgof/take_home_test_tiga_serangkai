<template>
  <div id="app">
    <div v-if="isAuthenticated" class="layout">

      <aside class="sidebar">
        <div class="logo">
          Mini Wallet
        </div>

        <nav class="menu-list">
          <router-link to="/dashboard" class="menu">
            Dashboard
          </router-link>

          <router-link to="/transfer" class="menu">
            Transfer
          </router-link>

          <router-link to="/transactions" class="menu">
            Riwayat
          </router-link>
        </nav>

        <button class="logout" @click="handleLogout">
          Logout
        </button>

      </aside>

      <main class="content">
        <header class="topbar">
          <div class="page-title">
            Mini Wallet
          </div>

          <div class="profile">
            <div class="avatar">
              {{ userName.charAt(0).toUpperCase() }}
            </div>

            <span class="username">
              {{ userName }}
            </span>
          </div>
        </header>

        <div class="page-content">
          <router-view />
        </div>
      </main>

    </div>

    <router-view v-else />

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'App',

  computed: {
    ...mapGetters([
      'isAuthenticated',
      'userName'
    ])
  },

  methods: {
    ...mapActions([
      'logout'
    ]),

    async handleLogout() {
      await this.logout()
      this.$router.push('/login')
    }
  }
}
</script>

<style lang="scss">
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html,
body,
#app {
  height: 100%;
}

body {
  font-family: Inter, "Segoe UI", sans-serif;
  background: #f8fafc;
  color: #1f2937;
}

.layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 250px;
  background: #ffffff;
  border-right: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0,0,0,.05);
  display: flex;
  flex-direction: column;
  padding: 24px;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
}

.logo {
  font-size: 24px;
  font-weight: 700;
  color: #2563eb;
  margin-bottom: 40px;
}

.menu-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.menu {
  text-decoration: none;
  color: #374151;
  padding: 12px 16px;
  border-radius: 12px;
  transition: all .2s ease;
}

.menu:hover {
  background: #f3f4f6;
}

.router-link-active {
  background: #2563eb;
  color: white;
  font-weight: 600;
}

.logout {
  margin-top: auto;
  border: none;
  background: #ef4444;
  color: white;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: .2s;
}

.logout:hover {
  background: #dc2626;
}

.content {
  flex: 1;
  margin-left: 250px;
  background: #f8fafc;
  min-height: 100vh;
}

.topbar {
  height: 72px;
  background: white;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
}

.profile {
  display: flex;
  align-items: center;
  gap: 10px;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #2563eb;
  color: white;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
}

.username {
  font-size: 14px;
  font-weight: 500;
}

.page-content {
  padding: 24px;
}

.card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0,0,0,.05);
}

@media (max-width: 768px) {
  .sidebar {
    width: 220px;
  }

  .content {
    margin-left: 220px;
  }
}

@media (max-width: 640px) {
  .layout {
    flex-direction: column;
  }

  .sidebar {
    position: relative;
    width: 100%;
    border-right: none;
    border-bottom: 1px solid #e5e7eb;
  }

  .content {
    margin-left: 0;
  }

  .topbar {
    padding: 0 16px;
  }

  .page-content {
    padding: 16px;
  }
}
</style>