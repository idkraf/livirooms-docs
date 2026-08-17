<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HotelFaq extends Model
{
    protected $table = 'hotel_faqs';

    protected $fillable = [
        'hotel_id',
        'question',
        'answer',
        'author_name',
        'author_role',
        'sort_order',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }
}
