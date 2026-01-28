const formatPercent = (value) => {
  if (value === null || isNaN(value)) return 'N/A';
  return Math.round(value * 100);
};

export default {
  formatPercent
};