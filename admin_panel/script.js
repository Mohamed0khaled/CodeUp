// Admin Panel JavaScript
class AdminPanel {
    constructor() {
        this.currentSection = 'dashboard';
        this.tournaments = this.loadTournaments();
        this.currentPage = 1;
        this.itemsPerPage = 6;
        this.searchQuery = '';
        this.statusFilter = '';
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.renderTournaments();
        this.showSection('dashboard');
    }

    setupEventListeners() {
        // Sidebar navigation
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('click', (e) => {
                const section = e.currentTarget.dataset.section;
                this.showSection(section);
            });
        });

        // Mobile menu toggle
        const menuToggle = document.querySelector('.menu-toggle');
        const sidebar = document.querySelector('.sidebar');
        menuToggle?.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });

        // Tournament management
        document.getElementById('addTournamentBtn')?.addEventListener('click', () => {
            this.openTournamentModal();
        });

        // Modal controls
        document.querySelector('.modal-close')?.addEventListener('click', () => {
            this.closeTournamentModal();
        });

        document.getElementById('cancelBtn')?.addEventListener('click', () => {
            this.closeTournamentModal();
        });

        // Tournament form submission
        document.getElementById('tournamentForm')?.addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveTournament();
        });

        // Search and filter
        document.getElementById('tournamentSearch')?.addEventListener('input', (e) => {
            this.searchQuery = e.target.value.toLowerCase();
            this.currentPage = 1;
            this.renderTournaments();
        });

        document.getElementById('statusFilter')?.addEventListener('change', (e) => {
            this.statusFilter = e.target.value;
            this.currentPage = 1;
            this.renderTournaments();
        });

        // Pagination
        document.getElementById('prevPage')?.addEventListener('click', () => {
            if (this.currentPage > 1) {
                this.currentPage--;
                this.renderTournaments();
            }
        });

        document.getElementById('nextPage')?.addEventListener('click', () => {
            const maxPages = Math.ceil(this.getFilteredTournaments().length / this.itemsPerPage);
            if (this.currentPage < maxPages) {
                this.currentPage++;
                this.renderTournaments();
            }
        });

        // Close modal when clicking outside
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeTournamentModal();
                this.closeConfirmModal();
            }
        });

        // Prize distribution auto-calculation
        const prizeInputs = ['firstPrize', 'secondPrize', 'thirdPrize'];
        prizeInputs.forEach(id => {
            document.getElementById(id)?.addEventListener('input', () => {
                this.validatePrizeDistribution();
            });
        });
    }

    showSection(sectionName) {
        // Update sidebar active state
        document.querySelectorAll('.menu-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionName}"]`)?.classList.add('active');

        // Update page title
        const pageTitle = document.querySelector('.page-title');
        if (pageTitle) {
            pageTitle.textContent = this.capitalize(sectionName);
        }

        // Show/hide sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(sectionName)?.classList.add('active');

        this.currentSection = sectionName;

        // Load section-specific data
        if (sectionName === 'tournaments') {
            this.renderTournaments();
        }
    }

    // Tournament Management
    loadTournaments() {
        const stored = localStorage.getItem('admin_tournaments');
        if (stored) {
            return JSON.parse(stored);
        }

        // Default tournament data
        return [
            {
                id: 1,
                title: 'Algorithm Sprint',
                subtitle: 'Weekly coding challenge',
                startDate: '2024-11-15T10:00',
                duration: 3,
                prizePool: 5000,
                maxParticipants: 200,
                participants: 128,
                difficulty: 'Medium',
                language: 'Any',
                status: 'open',
                description: 'Test your algorithmic skills in this weekly challenge.',
                rules: [
                    'Duration: 3 Hours',
                    'Language: Any programming language allowed',
                    'Scoring: Speed + Accuracy',
                    'Difficulty: Easy to Hard problems'
                ],
                prizes: { first: 50, second: 30, third: 20 },
                createdAt: new Date().toISOString()
            },
            {
                id: 2,
                title: 'Data Structure Masters',
                subtitle: 'Advanced DS challenges',
                startDate: '2024-11-20T14:00',
                duration: 4,
                prizePool: 8000,
                maxParticipants: 150,
                participants: 89,
                difficulty: 'Hard',
                language: 'C++/Java',
                status: 'open',
                description: 'Master complex data structures and algorithms.',
                rules: [
                    'Duration: 4 Hours',
                    'Language: C++ or Java only',
                    'Scoring: Based on time complexity and correctness',
                    'Difficulty: Medium to Hard problems'
                ],
                prizes: { first: 50, second: 30, third: 20 },
                createdAt: new Date().toISOString()
            },
            {
                id: 3,
                title: 'Web Dev Championship',
                subtitle: 'Full-stack challenge',
                startDate: '2024-11-25T09:00',
                duration: 6,
                prizePool: 12000,
                maxParticipants: 300,
                participants: 156,
                difficulty: 'Expert',
                language: 'JavaScript',
                status: 'ongoing',
                description: 'Build a complete web application in 6 hours.',
                rules: [
                    'Duration: 6 Hours',
                    'Language: JavaScript (React/Node.js)',
                    'Scoring: Functionality + Design + Performance',
                    'Must deploy to live server'
                ],
                prizes: { first: 50, second: 30, third: 20 },
                createdAt: new Date().toISOString()
            }
        ];
    }

    saveTournaments() {
        localStorage.setItem('admin_tournaments', JSON.stringify(this.tournaments));
    }

    getFilteredTournaments() {
        let filtered = [...this.tournaments];

        if (this.searchQuery) {
            filtered = filtered.filter(tournament => 
                tournament.title.toLowerCase().includes(this.searchQuery) ||
                tournament.subtitle.toLowerCase().includes(this.searchQuery) ||
                tournament.difficulty.toLowerCase().includes(this.searchQuery)
            );
        }

        if (this.statusFilter) {
            filtered = filtered.filter(tournament => tournament.status === this.statusFilter);
        }

        return filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    }

    renderTournaments() {
        const grid = document.getElementById('tournamentsGrid');
        if (!grid) return;

        const filtered = this.getFilteredTournaments();
        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;
        const currentTournaments = filtered.slice(startIndex, endIndex);

        if (currentTournaments.length === 0) {
            grid.innerHTML = `
                <div class="no-tournaments">
                    <i class="fas fa-trophy"></i>
                    <h3>No tournaments found</h3>
                    <p>Create your first tournament to get started.</p>
                </div>
            `;
            return;
        }

        grid.innerHTML = currentTournaments.map(tournament => this.createTournamentCard(tournament)).join('');
        this.renderPagination(filtered.length);
        this.attachTournamentEvents();
    }

    createTournamentCard(tournament) {
        const statusClass = `status-${tournament.status}`;
        const participationPercentage = Math.round((tournament.participants / tournament.maxParticipants) * 100);
        
        // Calculate prize amounts
        const firstPrize = Math.round(tournament.prizePool * tournament.prizes.first / 100);
        const secondPrize = Math.round(tournament.prizePool * tournament.prizes.second / 100);
        const thirdPrize = Math.round(tournament.prizePool * tournament.prizes.third / 100);

        const colors = this.getTournamentColors(tournament.difficulty);

        return `
            <div class="tournament-card" style="--card-color-1: ${colors.primary}; --card-color-2: ${colors.secondary};">
                <div class="tournament-header">
                    <div class="tournament-info">
                        <h3>${tournament.title}</h3>
                        <p>${tournament.subtitle}</p>
                    </div>
                    <span class="tournament-status ${statusClass}">${tournament.status}</span>
                </div>
                
                <div class="tournament-details">
                    <div class="detail-item">
                        <i class="fas fa-calendar"></i>
                        <span>${this.formatDate(tournament.startDate)}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <span>${tournament.duration}h</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-dollar-sign"></i>
                        <span>$${tournament.prizePool.toLocaleString()}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-users"></i>
                        <span>${tournament.participants}/${tournament.maxParticipants}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-signal"></i>
                        <span>${tournament.difficulty}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-code"></i>
                        <span>${tournament.language}</span>
                    </div>
                </div>

                <div class="prize-preview">
                    <small>Prize Distribution:</small>
                    <div class="prize-amounts">
                        <span>🥇 $${firstPrize.toLocaleString()}</span>
                        <span>🥈 $${secondPrize.toLocaleString()}</span>
                        <span>🥉 $${thirdPrize.toLocaleString()}</span>
                    </div>
                </div>

                <div class="tournament-actions">
                    <button class="action-btn edit" onclick="adminPanel.editTournament(${tournament.id})">
                        <i class="fas fa-edit"></i>
                        Edit
                    </button>
                    <button class="action-btn delete" onclick="adminPanel.deleteTournament(${tournament.id})">
                        <i class="fas fa-trash"></i>
                        Delete
                    </button>
                </div>
            </div>
        `;
    }

    getTournamentColors(difficulty) {
        const colors = {
            Easy: { primary: '#10b981', secondary: '#06b6d4' },
            Medium: { primary: '#3b82f6', secondary: '#06b6d4' },
            Hard: { primary: '#8b5cf6', secondary: '#ec4899' },
            Expert: { primary: '#ef4444', secondary: '#f59e0b' }
        };
        return colors[difficulty] || colors.Medium;
    }

    renderPagination(totalItems) {
        const maxPages = Math.ceil(totalItems / this.itemsPerPage);
        const pageNumbers = document.getElementById('pageNumbers');
        const prevBtn = document.getElementById('prevPage');
        const nextBtn = document.getElementById('nextPage');

        if (!pageNumbers) return;

        // Update navigation buttons
        prevBtn.disabled = this.currentPage === 1;
        nextBtn.disabled = this.currentPage === maxPages || maxPages === 0;

        // Generate page numbers
        let pages = '';
        for (let i = 1; i <= maxPages; i++) {
            if (i === 1 || i === maxPages || (i >= this.currentPage - 1 && i <= this.currentPage + 1)) {
                pages += `<button class="page-number ${i === this.currentPage ? 'active' : ''}" onclick="adminPanel.goToPage(${i})">${i}</button>`;
            } else if (i === this.currentPage - 2 || i === this.currentPage + 2) {
                pages += `<span class="page-ellipsis">...</span>`;
            }
        }

        pageNumbers.innerHTML = pages;
    }

    goToPage(page) {
        this.currentPage = page;
        this.renderTournaments();
    }

    attachTournamentEvents() {
        // Events are attached via onclick attributes in the HTML
    }

    openTournamentModal(tournament = null) {
        const modal = document.getElementById('tournamentModal');
        const form = document.getElementById('tournamentForm');
        const title = document.getElementById('modalTitle');

        if (tournament) {
            title.textContent = 'Edit Tournament';
            this.populateForm(tournament);
        } else {
            title.textContent = 'Add Tournament';
            form.reset();
            // Set default values
            document.getElementById('firstPrize').value = 50;
            document.getElementById('secondPrize').value = 30;
            document.getElementById('thirdPrize').value = 20;
        }

        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    closeTournamentModal() {
        const modal = document.getElementById('tournamentModal');
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }

    populateForm(tournament) {
        document.getElementById('tournamentTitle').value = tournament.title;
        document.getElementById('tournamentSubtitle').value = tournament.subtitle;
        document.getElementById('startDate').value = tournament.startDate;
        document.getElementById('duration').value = tournament.duration;
        document.getElementById('prizePool').value = tournament.prizePool;
        document.getElementById('maxParticipants').value = tournament.maxParticipants;
        document.getElementById('difficulty').value = tournament.difficulty;
        document.getElementById('language').value = tournament.language;
        document.getElementById('description').value = tournament.description;
        document.getElementById('rules').value = tournament.rules.join('\n');
        document.getElementById('firstPrize').value = tournament.prizes.first;
        document.getElementById('secondPrize').value = tournament.prizes.second;
        document.getElementById('thirdPrize').value = tournament.prizes.third;

        // Store the tournament ID for editing
        document.getElementById('tournamentForm').dataset.editId = tournament.id;
    }

    validatePrizeDistribution() {
        const first = parseInt(document.getElementById('firstPrize').value) || 0;
        const second = parseInt(document.getElementById('secondPrize').value) || 0;
        const third = parseInt(document.getElementById('thirdPrize').value) || 0;
        const total = first + second + third;

        // Visual feedback for prize distribution
        const inputs = [document.getElementById('firstPrize'), document.getElementById('secondPrize'), document.getElementById('thirdPrize')];
        inputs.forEach(input => {
            input.style.borderColor = total === 100 ? '#10b981' : '#ef4444';
        });

        return total === 100;
    }

    saveTournament() {
        const form = document.getElementById('tournamentForm');
        const editId = form.dataset.editId;

        // Validate prize distribution
        if (!this.validatePrizeDistribution()) {
            this.showNotification('Prize distribution must total 100%', 'error');
            return;
        }

        // Collect form data
        const formData = {
            title: document.getElementById('tournamentTitle').value,
            subtitle: document.getElementById('tournamentSubtitle').value,
            startDate: document.getElementById('startDate').value,
            duration: parseInt(document.getElementById('duration').value),
            prizePool: parseInt(document.getElementById('prizePool').value),
            maxParticipants: parseInt(document.getElementById('maxParticipants').value),
            difficulty: document.getElementById('difficulty').value,
            language: document.getElementById('language').value,
            description: document.getElementById('description').value,
            rules: document.getElementById('rules').value.split('\n').filter(rule => rule.trim()),
            prizes: {
                first: parseInt(document.getElementById('firstPrize').value),
                second: parseInt(document.getElementById('secondPrize').value),
                third: parseInt(document.getElementById('thirdPrize').value)
            }
        };

        if (editId) {
            // Edit existing tournament
            const index = this.tournaments.findIndex(t => t.id === parseInt(editId));
            if (index !== -1) {
                this.tournaments[index] = {
                    ...this.tournaments[index],
                    ...formData,
                    updatedAt: new Date().toISOString()
                };
                this.showNotification('Tournament updated successfully!', 'success');
            }
        } else {
            // Add new tournament
            const newTournament = {
                id: Date.now(),
                ...formData,
                participants: 0,
                status: 'open',
                createdAt: new Date().toISOString()
            };
            this.tournaments.push(newTournament);
            this.showNotification('Tournament created successfully!', 'success');
        }

        this.saveTournaments();
        this.renderTournaments();
        this.closeTournamentModal();
        delete form.dataset.editId;
    }

    editTournament(id) {
        const tournament = this.tournaments.find(t => t.id === id);
        if (tournament) {
            this.openTournamentModal(tournament);
        }
    }

    deleteTournament(id) {
        const tournament = this.tournaments.find(t => t.id === id);
        if (!tournament) return;

        this.showConfirmModal(
            'Delete Tournament',
            `Are you sure you want to delete "${tournament.title}"? This action cannot be undone.`,
            () => {
                this.tournaments = this.tournaments.filter(t => t.id !== id);
                this.saveTournaments();
                this.renderTournaments();
                this.showNotification('Tournament deleted successfully!', 'success');
            }
        );
    }

    showConfirmModal(title, message, onConfirm) {
        const modal = document.getElementById('confirmModal');
        document.getElementById('confirmTitle').textContent = title;
        document.getElementById('confirmMessage').textContent = message;

        const confirmBtn = document.getElementById('confirmDelete');
        const cancelBtn = document.getElementById('confirmCancel');

        // Remove existing event listeners
        confirmBtn.replaceWith(confirmBtn.cloneNode(true));
        cancelBtn.replaceWith(cancelBtn.cloneNode(true));

        // Add new event listeners
        document.getElementById('confirmDelete').addEventListener('click', () => {
            onConfirm();
            this.closeConfirmModal();
        });

        document.getElementById('confirmCancel').addEventListener('click', () => {
            this.closeConfirmModal();
        });

        modal.classList.add('active');
    }

    closeConfirmModal() {
        document.getElementById('confirmModal').classList.remove('active');
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'times' : 'info'}-circle"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close">&times;</button>
        `;

        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#06b6d4'};
            color: white;
            padding: 16px 20px;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            z-index: 3000;
            display: flex;
            align-items: center;
            gap: 12px;
            max-width: 400px;
            animation: slideInRight 0.3s ease;
        `;

        // Add to document
        document.body.appendChild(notification);

        // Remove notification after 5 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                notification.remove();
            }, 300);
        }, 5000);

        // Close button
        notification.querySelector('.notification-close').addEventListener('click', () => {
            notification.remove();
        });
    }

    // Utility functions
    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
}

// CSS for notifications
const notificationStyles = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
    
    .notification-close {
        background: none;
        border: none;
        color: white;
        font-size: 18px;
        cursor: pointer;
        padding: 4px;
        border-radius: 4px;
        transition: background 0.3s ease;
    }
    
    .notification-close:hover {
        background: rgba(255,255,255,0.2);
    }
    
    .no-tournaments {
        grid-column: 1 / -1;
        text-align: center;
        padding: 60px 20px;
        color: rgba(255,255,255,0.6);
    }
    
    .no-tournaments i {
        font-size: 48px;
        margin-bottom: 16px;
        color: rgba(255,255,255,0.3);
    }
    
    .no-tournaments h3 {
        font-size: 24px;
        margin-bottom: 8px;
        color: rgba(255,255,255,0.8);
    }
    
    .prize-preview {
        margin-top: 12px;
        padding: 12px;
        background: rgba(255,255,255,0.05);
        border-radius: 8px;
    }
    
    .prize-preview small {
        color: rgba(255,255,255,0.6);
        font-size: 12px;
        display: block;
        margin-bottom: 8px;
    }
    
    .prize-amounts {
        display: flex;
        gap: 12px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .prize-amounts span {
        color: rgba(255,255,255,0.8);
    }
    
    .page-ellipsis {
        color: rgba(255,255,255,0.5);
        padding: 0 8px;
        font-weight: bold;
    }
`;

// Add notification styles to the document
const styleSheet = document.createElement('style');
styleSheet.textContent = notificationStyles;
document.head.appendChild(styleSheet);

// Initialize the admin panel when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.adminPanel = new AdminPanel();
});
