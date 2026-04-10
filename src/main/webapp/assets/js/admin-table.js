/**
 * AdminTable - Client-side filter and pagination for admin tables
 */
const AdminTable = (function() {
    const DEFAULT_PER_PAGE = 10;
    const PER_PAGE_OPTIONS = [10, 25, 50, 100];

    const state = {};

    function init(tableId, options = {}) {
        const table = document.getElementById(tableId);
        if (!table) return;

        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr[data-row]'));

        state[tableId] = {
            allRows: rows,
            filteredRows: rows,
            currentPage: 1,
            perPage: options.perPage || DEFAULT_PER_PAGE,
            paginationId: options.paginationId || `${tableId}-pagination`
        };

        render(tableId);
    }

    function filter(tableId, filters) {
        const s = state[tableId];
        if (!s) return;

        s.filteredRows = s.allRows.filter(row => {
            return Object.entries(filters).every(([key, value]) => {
                if (!value) return true;
                const cell = row.querySelector(`[data-field="${key}"]`);
                if (!cell) {
                    const cellText = row.textContent.toLowerCase();
                    return cellText.includes(value.toLowerCase());
                }
                const cellValue = (cell.dataset.value || cell.textContent).toLowerCase();
                return cellValue.includes(value.toLowerCase());
            });
        });

        s.currentPage = 1;
        render(tableId);
    }

    function setPage(tableId, page) {
        const s = state[tableId];
        if (!s) return;

        const totalPages = Math.ceil(s.filteredRows.length / s.perPage) || 1;
        s.currentPage = Math.max(1, Math.min(page, totalPages));
        render(tableId);
    }

    function setPerPage(tableId, perPage) {
        const s = state[tableId];
        if (!s) return;

        s.perPage = perPage;
        s.currentPage = 1;
        render(tableId);
    }

    function render(tableId) {
        const s = state[tableId];
        if (!s) return;

        const start = (s.currentPage - 1) * s.perPage;
        const end = start + s.perPage;
        const totalPages = Math.ceil(s.filteredRows.length / s.perPage) || 1;

        s.allRows.forEach(row => row.style.display = 'none');
        s.filteredRows.slice(start, end).forEach(row => row.style.display = '');

        renderPagination(tableId, s.filteredRows.length, s.currentPage, s.perPage, totalPages);
    }

    function renderPagination(tableId, total, currentPage, perPage, totalPages) {
        const container = document.getElementById(state[tableId].paginationId);
        if (!container) return;

        const start = total === 0 ? 0 : (currentPage - 1) * perPage + 1;
        const end = Math.min(currentPage * perPage, total);

        let html = `
            <div class="pagination-wrapper">
                <div class="pagination-info">
                    <span>Hi\u1EC3n th\u1ECB ${start}-${end} c\u1EE7a ${total}</span>
                </div>
                <div class="pagination-controls">
                    <div class="per-page-wrapper">
                        <select class="per-page-select" onchange="AdminTable.setPerPage('${tableId}', parseInt(this.value))">
                            ${PER_PAGE_OPTIONS.map(opt =>
                                `<option value="${opt}" ${opt === perPage ? 'selected' : ''}>${opt}</option>`
                            ).join('')}
                        </select>
                        <span class="per-page-label">/ trang</span>
                    </div>
                    <div class="pagination-nav">
                        <button type="button" class="page-btn" title="Trang đầu"
                            onclick="AdminTable.setPage('${tableId}', 1)" ${currentPage === 1 ? 'disabled' : ''}>
                            <i class="bi bi-chevron-double-left"></i>
                        </button>
                        <button type="button" class="page-btn" title="Trang trước"
                            onclick="AdminTable.setPage('${tableId}', ${currentPage - 1})" ${currentPage === 1 ? 'disabled' : ''}>
                            <i class="bi bi-chevron-left"></i>
                        </button>
                        <span class="page-indicator">${currentPage} / ${totalPages}</span>
                        <button type="button" class="page-btn" title="Trang sau"
                            onclick="AdminTable.setPage('${tableId}', ${currentPage + 1})" ${currentPage === totalPages ? 'disabled' : ''}>
                            <i class="bi bi-chevron-right"></i>
                        </button>
                        <button type="button" class="page-btn" title="Trang cuối"
                            onclick="AdminTable.setPage('${tableId}', ${totalPages})" ${currentPage === totalPages ? 'disabled' : ''}>
                            <i class="bi bi-chevron-double-right"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
        container.innerHTML = html;
    }

    function bindFilters(tableId, formId) {
        const form = document.getElementById(formId);
        if (!form) return;

        const inputs = form.querySelectorAll('input, select');
        inputs.forEach(input => {
            input.addEventListener('input', debounce(() => {
                const filters = {};
                inputs.forEach(el => {
                    if (el.name && el.value) {
                        filters[el.name] = el.value;
                    }
                });
                filter(tableId, filters);
            }, 300));
        });

        form.addEventListener('submit', e => e.preventDefault());
    }

    function debounce(fn, delay) {
        let timer;
        return function(...args) {
            clearTimeout(timer);
            timer = setTimeout(() => fn.apply(this, args), delay);
        };
    }

    return { init, filter, setPage, setPerPage, bindFilters };
})();
