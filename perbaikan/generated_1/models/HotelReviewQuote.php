<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HotelReviewQuote extends Model
{
    protected $table = 'hotel_review_quotes';

    protected $fillable = [
        'hotel_id',
        'quote',
        'author_name',
        'author_role',
        'rating',
        'sort_order',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }
}
