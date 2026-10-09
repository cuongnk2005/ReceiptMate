/**
 * Mock Data for 4-Status Ticket Board Prototype
 * Resets to clean baseline state on page reload
 */

export const STATUS_CONFIG = [
  { id: 'backlog', title: 'Backlog', ruleColor: '#9E998F' },
  { id: 'todo', title: 'To Do', ruleColor: '#2D5B88' },
  { id: 'in_progress', title: 'In Progress', ruleColor: '#C25E3E' },
  { id: 'done', title: 'Done', ruleColor: '#3E6B48' }
];

export const INITIAL_TICKETS = [
  {
    id: 'TCK-101',
    title: 'Implement on-device OCR regex parser for VND',
    description: 'Ensure dots and commas are stripped from numbers, and normalize expressions like 45k to 45000.',
    status: 'backlog',
    tags: ['ocr', 'parser', 'core'],
    createdAt: '2026-10-09T08:00:00Z',
    updatedAt: '2026-10-09T08:00:00Z'
  },
  {
    id: 'TCK-102',
    title: 'Design fallback Review & Verification screen',
    description: 'Enforce the "Never Trust OCR Blindly" rule. Form validation must guard against missing merchant or zero amount.',
    status: 'backlog',
    tags: ['ui', 'security'],
    createdAt: '2026-10-09T08:30:00Z',
    updatedAt: '2026-10-09T08:30:00Z'
  },
  {
    id: 'TCK-103',
    title: 'Set up sqflite local persistence table schema',
    description: 'Add composite indexes for transaction_date and category to guarantee sub-50ms query latency.',
    status: 'todo',
    tags: ['sqlite', 'database'],
    createdAt: '2026-10-09T09:00:00Z',
    updatedAt: '2026-10-09T09:00:00Z'
  },
  {
    id: 'TCK-104',
    title: 'Construct CustomPainter Category Donut chart',
    description: 'Zero third-party charting libraries. Compute sweep angles manually and animate via AnimationController.',
    status: 'in_progress',
    tags: ['canvas', 'chart', 'm3'],
    createdAt: '2026-10-09T09:45:00Z',
    updatedAt: '2026-10-09T10:15:00Z'
  },
  {
    id: 'TCK-105',
    title: 'Weekly 7-day bar chart with tooltip feedback',
    description: 'Draw rounded RRect bars with 6px radius and render dynamic weekday labels underneath each column.',
    status: 'done',
    tags: ['canvas', 'performance'],
    createdAt: '2026-10-09T07:15:00Z',
    updatedAt: '2026-10-09T11:00:00Z'
  }
];
